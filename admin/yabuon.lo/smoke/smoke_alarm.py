#!/usr/bin/env python -u
import sys, os
import RPi.GPIO as GPIO
import time
import requests
from datetime import datetime

sys.stdout.reconfigure(line_buffering=True)

## Global variables to be altered
gCounts = 0
gEventTime = None
gLogTime = 0

## Constants
cGPIO = 21
cBounceTime = 10
cThreshold = 7
cTimeout = 5
cCoolDownTime = 30
cLogInterval = 3600

WEBHOOK_HEPMM = os.environ.get("WEBHOOK_HEPMM", "")
WEBHOOK_CPNRDC = os.environ.get("WEBHOOK_CPNRDC", "")
WEBHOOK_SICDC = os.environ.get("WEBHOOK_SICDC", "")
WEBHOOK_INFLUX = os.environ.get("WEBHOOK_INFLUX", "")
TOKEN_INFLUX = os.environ.get("TOKEN_INFLUX", "")

def send_MM(msg, url):
    requests.post(url, json={"text": msg})

def send_DC(msg, url):
    requests.post(url, json={"content": msg})

def alarm_callback(channel):
    global gCounts, gEventTime
    if gCounts == 0:
        gEventTime = time.time()
    gCounts += 1

def send_alerts():
    nowStr = datetime.fromtimestamp(gEventTime).strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
    msg = f"""ALERT: \U0001F525 FIRE ALARM on {nowStr} !!!!
Please rush to the \ud478\ub978\uc194 cluster room and check what is happening !!!
GPIO={cGPIO} counts={gCounts} threshold={cThreshold}"""
    print(msg)
    send_MM(msg, WEBHOOK_HEPMM)
    send_DC(msg, WEBHOOK_CPNRDC)
    send_DC(msg, WEBHOOK_SICDC)

def send_influx(now):
    global gLogTime, gCounts, cLogInterval
    if now - gLogTime < cLogInterval:
        return

    measurement = "smoke"
    fields = {"counts":gCounts}
    line = f"{measurement} " + ",".join(f"{k}={v}" for k,v in fields.items()) + f" {int(now)}"
    #print(line)
    requests.post(WEBHOOK_INFLUX, data=line, headers={"Authorization": f"Token {TOKEN_INFLUX}"})

    gLogTime = now

if __name__ == '__main__':
    print("Initializing...")

    GPIO.setmode(GPIO.BCM)
    GPIO.setup(cGPIO, GPIO.IN, pull_up_down=GPIO.PUD_UP)

    if WEBHOOK_HEPMM == "":
        print("Could not find proper webhook URL...")
        sys.exit(2)

    if '--test' in sys.argv:
        print("Starting test mode...")
        alarm_callback(cGPIO)
        GPIO.cleanup()

    else:
        print("Registering callbacks...")
        GPIO.add_event_detect(cGPIO, GPIO.FALLING, callback=alarm_callback, bouncetime=cBounceTime)
        try:
            print("Starting the main loop..")
            while True:
                time.sleep(0.5)
                now = time.time()

                #send_influx(now) ## Does not work in some reason...

                if gCounts >= cThreshold:
                    send_alerts()
                    gCounts = 0
                    gEventTime = None
                    time.sleep(cCoolDownTime)
                elif gEventTime and now - gEventTime > cTimeout:
                    print(f"Time window is expired. Reset counts={gCounts}")
                    gCounts = 0
                    gEventTime = None

        except KeyboardInterrupt:
            GPIO.cleanup()
