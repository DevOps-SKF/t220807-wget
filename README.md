# ЗАДАНИЕ 22.8.7

## Задача

Создайте Docker-образ приложения, которое будет при запуске контейнера скачивать favicon заданного приложению сайта.  
Затем попробуйте улучшить этот Docker-образ согласно изученным лучшим практикам.

## Решение

Пробовал сделать multi-stage build (`Dockerfile-`)  
Оказалось, что недостаточно скопировать wget с библиотеками, подсказанными ldd:

    anton@skfubu:~/SKF/Task-22_8_7$ docker run -it skf /bin/sh
    # ldd /bin/sh
            linux-vdso.so.1 (0x00007ffd855ff000)
            libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fbf5f4cc000)
            /lib64/ld-linux-x86-64.so.2 (0x00007fbf5f6e5000)
    # ldd /usr/bin/wget
            linux-vdso.so.1 (0x00007fff4f075000)
            libpcre2-8.so.0 => /lib/x86_64-linux-gnu/libpcre2-8.so.0 (0x00007ff0ab42a000)
            libuuid.so.1 => /lib/x86_64-linux-gnu/libuuid.so.1 (0x00007ff0ab421000)
            libidn2.so.0 => /lib/x86_64-linux-gnu/libidn2.so.0 (0x00007ff0ab400000)
            libssl.so.1.1 => /lib/x86_64-linux-gnu/libssl.so.1.1 (0x00007ff0ab36d000)
            libcrypto.so.1.1 => /lib/x86_64-linux-gnu/libcrypto.so.1.1 (0x00007ff0ab097000)
            libz.so.1 => /lib/x86_64-linux-gnu/libz.so.1 (0x00007ff0ab07b000)
            libpsl.so.5 => /lib/x86_64-linux-gnu/libpsl.so.5 (0x00007ff0ab066000)
            libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007ff0aae74000)
            libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007ff0aae51000)
            /lib64/ld-linux-x86-64.so.2 (0x00007ff0ab54c000)
            libunistring.so.2 => /lib/x86_64-linux-gnu/libunistring.so.2 (0x00007ff0aaccf000)
            libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007ff0aacc9000)

А что добавить для name resolution не нашел.  

    --2021-07-18 17:54:05--  http://www.ru/
    Resolving www.ru (www.ru)... failed: Device or resource busy.
    wget: unable to resolve host address 'www.ru'

Впрочем, на основе alpine размер и так мизерный, не вижу смысла заморачиваться.

    anton@skfubu:~$ docker images
    REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
    skf          latest    6bc33af06d40   33 minutes ago   9.96MB
    ubuntu       20.04     c29284518f49   4 days ago       72.8MB
    alpine       3.14      d4ff818577bc   4 weeks ago      5.6MB

Dockerfile:

    FROM alpine:3.14
    RUN apk add wget
    WORKDIR /data
    ENTRYPOINT ["sh", "-c", "/usr/bin/wget ${0}/favicon.ico"]

### Дополнение

При `docker build -t skf:latest .` новая версия становится `skf:latest`, а старая остается `<none>`

    anton@skfubu:/tmp$ docker images
    REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
    skf          latest    cb8e35d76ab7   30 minutes ago   110MB
    <none>       <none>    b41cc130934c   32 minutes ago   110MB
    <none>       <none>    7974163e7975   35 minutes ago   72.8MB
    <none>       <none>    9f2a77b82a4d   38 minutes ago   72.8MB
    <none>       <none>    a882c526365a   41 minutes ago   72.8MB
    <none>       <none>    593f1cd5ecdd   5 hours ago      72.8MB
    ubuntu       20.04     c29284518f49   4 days ago       72.8MB

Для удаления всех образов без тэгов использую:

    for i in $(docker images | grep "<none>" | tr -s ' ' | cut -d ' ' -f3); do docker rmi $i; done

Аналогично чищу контейнеры, если забывал указать имя и флаг `--rm`

    for c in $(docker ps -a | cut -d ' ' -f1) ; do docker rm $c; done

## Запуск

    docker run --rm -i -v /tmp:/data skf www.ru

favicon.ico появится в /tmp

Для запуска "без подробностей":

    docker run --rm -i -v /tmp:/data skf www.ru -q 

Вместо монтирования директории можно воспользоваться `docker cp`. Но тогда вместо автоматического удаления контейнера (`run --rm`) следует для запуска использовать `exec`

### Результат

    anton@skfubu:/tmp$ docker run --rm -it -v /tmp:/data skf www.ru
    --2021-07-18 15:39:08--  http://www.ru/favicon.ico
    Resolving www.ru (www.ru)... 31.177.76.70, 31.177.80.70
    Connecting to www.ru (www.ru)|31.177.76.70|:80... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 15935 (16K) [text/html]
    Saving to: 'favicon.ico'

    favicon.ico                              100%[===============================================================================>]  15.56K  --.-KB/s    in 0.004s

    2021-07-18 15:39:08 (3.68 MB/s) - 'favicon.ico' saved [15935/15935]
