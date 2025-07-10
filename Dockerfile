FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DUDE_VERSION=4.0beta3
ENV DUDE_HOME=/dude
ENV WINEPREFIX=/wine
ARG DUDE_STUFF=dude-install-${DUDE_VERSION}.exe

# Инсталација на зависности
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates software-properties-common \
        curl wget unzip cabextract p7zip-full \
        netcat xvfb xauth \
        wine32 winbind winetricks && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Креирање структура
RUN mkdir -p ${DUDE_HOME} ${WINEPREFIX}/dlls

# Копирај инсталерот
COPY installer/${DUDE_STUFF} /${DUDE_STUFF}

# Распакувај инсталерот
RUN 7z x -o${DUDE_HOME} \
    -x!uninstall.exe \
    -x!data/files/*.ttf \
    -x!data/files/images/* \
    -x!data/files/mibs/* \
    /${DUDE_STUFF} && \
    chmod +x ${DUDE_HOME}/dude.exe && \
    rm -f /${DUDE_STUFF}

# Копирај DLL фајлови ако ги имаш
COPY container/wine-dlls/ ${WINEPREFIX}/dlls/

# Конфигурирај Wine Prefix
RUN WINEARCH=win32 WINEPREFIX=${WINEPREFIX} wineboot --init && \
    sleep 3 && \
    WINEPREFIX=${WINEPREFIX} winecfg -v winxp && \
    cp ${WINEPREFIX}/dlls/*.dll ${WINEPREFIX}/drive_c/windows/system32/ || true && \
    for dll in ${WINEPREFIX}/drive_c/windows/system32/*.dll; do \
        WINEPREFIX=${WINEPREFIX} wine regsvr32 "$dll" || true; \
    done && \
    WINEPREFIX=${WINEPREFIX} winetricks -q -f \
        corefonts fontsmooth-rgb gdiplus vb6run vcrun6 dcom98 \
        ole32 oleaut32 windowscodecs propsys shcore shlwapi || true

# Копирај хелтчек
COPY container/healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

# Копирај ентрипоинт
COPY container/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR ${DUDE_HOME}
ENV DISPLAY=:0
CMD ["/entrypoint.sh"]
