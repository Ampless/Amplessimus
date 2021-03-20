FROM cirrusci/flutter:dev

RUN apt update
RUN apt install -y clang
RUN apt install -y cmake
RUN apt install -y libgtk-3-dev
RUN apt install -y ninja-build
RUN apt install -y pkg-config
# seems to hang on ruby2.7-doc for like 10 minutes rn
RUN apt full-upgrade -y

#ARG GLIBC_VERSION="2.28-r0"

#ENV ANDROID_SDK_HOME /opt/android-sdk-linux
#ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
#ENV ANDROID_HOME /opt/android-sdk-linux
#ENV ANDROID_SDK /opt/android-sdk-linux
#ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk

# Install Required Tools
#RUN apk -U update && apk -U add \
#  bash \
#  ca-certificates \
#  curl \
#  expect \
#  fontconfig \
#  git \
#  make \
#  libstdc++ \
#  libgcc \
#  mesa-dev \
#  nodejs \
#  npm \
#  openjdk8 \
#  pulseaudio-dev \
#  su-exec \
#  ncurses \
#  unzip \
#  wget \
#  xz \
#  zlib \
#  && wget https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -O /etc/apk/keys/sgerrand.rsa.pub \
#	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk -O /tmp/glibc.apk \
#	&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk -O /tmp/glibc-bin.apk \
#	&& apk add /tmp/glibc.apk /tmp/glibc-bin.apk \
#  && rm -rf /tmp/* \
#	&& rm -rf /var/cache/apk/*

# Create android User
#RUN mkdir -p /opt/android-sdk-linux \
#  && addgroup android \
#  && adduser android -D -G android -h /opt/android-sdk-linux -u 1000

# Copy Tools
#COPY tools /opt/tools

# Copy Licenses
#COPY licenses /opt/licenses

# Working Directory
#WORKDIR /opt/android-sdk-linux

#RUN /opt/tools/entrypoint.sh built-in
#CMD /opt/tools/entrypoint.sh built-in

#FROM androidsdk/android-30

#ENV PATH $PATH:/flutter/bin

#RUN apt update
#RUN apt upgrade -y
#RUN apt install -y openjdk-8-jre
#RUN apt install -y android-sdk
#RUN apt install -y git curl unzip xz-utils make

#RUN git clone -b dev https://github.com/flutter/flutter.git /flutter

#RUN curl -Lo android-sdk-tools.zip https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
#    unzip -qq android-sdk-tools.zip -d /android_sdk && rm -f android-sdk-tools.zip
#
#RUN curl -Lo android-ndk.zip https://dl.google.com/android/repository/android-ndk-r22-linux-x86_64.zip && \
#    unzip -qq -o android-ndk.zip -d /android_sdk/ndk && \
#    mv -f /android_sdk/ndk/android-ndk-r22/* /android_sdk/ndk && \
#    rm -f android-ndk.zip

#RUN yes | sdkmanager --licenses && \
#	sdkmanager --update && \
#	sdkmanager tools platform-tools emulator "build-tools;30.0.0" "platforms;android-30" > /dev/null

RUN dart --version
RUN flutter precache --android --linux
RUN dart --disable-analytics
RUN flutter config --no-analytics

#RUN curl -Lo asdk.tgz https://dl.google.com/android/android-sdk_r24-linux.tgz && \
#    tar xvfz asdk.tgz && rm -f asdk.tgz

VOLUME /amp
WORKDIR /amp
