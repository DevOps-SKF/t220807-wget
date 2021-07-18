# ЗАДАНИЕ 22.8.7

## Задача

Создайте Docker-образ приложения, которое будет при запуске контейнера скачивать favicon заданного приложению сайта.  
Затем попробуйте улучшить этот Docker-образ согласно изученным лучшим практикам.

## Решение


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

## Запуск

    docker run --rm -i -v /tmp:/data skf www.ru

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

