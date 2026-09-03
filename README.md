# irpi

Infrared (active IR) camera stream from a Raspberry Pi 3A+ (OV5647 camera),
served by [MediaMTX](https://github.com/bluenviron/mediamtx).

## Usage

Set the Pi address in `.env` (optional, defaults to `pi@raspberrypi.local`):

```
PI=pi@irpi.local
```

Then:

```
make deploy   # install/update mediamtx and config on the Pi
make check    # list cameras detected on the Pi
make status   # show service status
make logs     # follow service logs
```

Feed: `http://<pi-ip>:8889/cam`
