# Dockerized automated Bluray remuxer
Build the image with:
```
$ docker build -t remuxer .
```


Run the docker container with:
```
docker run --privileged --name remux -v /path/to/sink:/sink -v /path/to/source:/source -v /path/to/config:/config remuxer
```

Where remuxable folders in `/path/to/source` (containing extracted Bluray ISOs or `.iso`'s) will be remuxed mkv's will end up in `/path/to/sink`. Filename will be based off of the folder name in `path/to/source`.

`/source` is checked every 5s for new folders, and it will attempt to remux the folder. A folder named `Movie.2009.Bluray` would result the remuxed version being present at `/sink/Movie.2009.Bluray.mkv`