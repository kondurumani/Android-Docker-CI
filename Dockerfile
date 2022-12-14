FROM ubuntu:18.04

# You can find out in here >>> https://developer.android.com/studio/index.html#command-tools
ENV VERSION_TOOLS "6514223"
# You can find out in /sdk/license/android-sdk-license
ENV ANDROID_SDK_LICENSE_HASH "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee"
# You can find out in /sdk/license/android-sdk-preview-license
ENV ANDROID_SDK_PREVIEW_LICENSE_HASH "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910"

ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools"
ENV DEBIAN_FRONTEND noninteractive

# Prepare dependencies
RUN apt-get -qq update \
 && apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      html2text \
      openjdk-8-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
      locales \
      ruby \
      ruby-rdoc \
      ruby-irb \
      ruby-dev \
      openssh \
      g++ \
      make \
      bash \
      build-essential \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Install sdk tools
RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip > /tools.zip \
 && mkdir -p ${ANDROID_HOME}/cmdline-tools \
 && unzip /tools.zip -d ${ANDROID_HOME}/cmdline-tools \
 && rm -v /tools.zip

# Accept android license
RUN mkdir -p $ANDROID_HOME/licenses/ \
 && echo ANDROID_SDK_LICENSE_HASH > $ANDROID_HOME/licenses/android-sdk-license \
 && echo ANDROID_SDK_PREVIEW_LICENSE_HASH > $ANDROID_HOME/licenses/android-sdk-preview-license \
 && yes | ${ANDROID_HOME}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses >/dev/null

# Add tools
ADD packages.txt /sdk
RUN mkdir -p /root/.android \
 && touch /root/.android/repositories.cfg \
 && ${ANDROID_HOME}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt \
 && ${ANDROID_HOME}/cmdline-tools/tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} ${PACKAGES}

# Add fastlane
RUN gem install fastlane -NV

 #firebase-tools setup
ADD https://github.com/firebase/firebase-tools/releases/download/v7.3.1/firebase-tools-linux firebase-tools-linux
RUN chmod +x firebase-tools-linux
RUN ./firebase-tools-linux --open-sesame appdistribution 
