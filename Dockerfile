# Base image
FROM ubuntu:18.04


# Up to date
RUN apt-get update && apt-get install -y curl python2.7 git
RUN ln -s /usr/bin/python2.7 /usr/bin/python2

ENV ATOLLIC_URL http://download.atollic.com/TrueSTUDIO/installers/Atollic_TrueSTUDIO_for_STM32_linux_x86_64_v9.3.0_20190212-0734.tar.gz
# Download truestudio
RUN echo 'Download TrueStudio and check md5sum' && \
  curl -O ${ATOLLIC_URL}     && \
  curl -O ${ATOLLIC_URL}.MD5 && \
  md5sum -c $(basename ${ATOLLIC_URL}.MD5) && \
  rm $(basename ${ATOLLIC_URL}.MD5) && \
  echo '- SUCCESS download ----------------------------'

# Install
ENV TRUESTUDIO_INSTALL_PATH /opt/Atollic_TrueSTUDIO_for_STM32_9.3.0

RUN installPath=${TRUESTUDIO_INSTALL_PATH} && \
  echo 'Add truestudio tools and truestudio and headless.sh to PATH' && \
  echo 'PATH="$PATH:'"${installPath}"'/ARMTools/bin:'"${installPath}"'/PCTools/bin"' >> /etc/bash.bashrc && \
  ln -s "${installPath}/ide/TrueSTUDIO" /usr/bin/ && \
  echo -ne '#!/bin/sh\ncd '"${installPath}"'/ide\nexec ./headless.sh "$@"\n' > /usr/bin/headless.sh && \
  chmod +x /usr/bin/headless.sh && \
  echo '- SUCCESS postinstall --------------------------'
  

# install in the second RUN
RUN echo 'Unpack and install truestudio' && \
  f=$(basename ${ATOLLIC_URL}) && \
  tar xzfvp $f && \
  installPath=${TRUESTUDIO_INSTALL_PATH} && \
  scriptPath=$(basename ${TRUESTUDIO_INSTALL_PATH})_installer && \
  cp ${scriptPath}/license.txt /ATOLLIC-END-USER-SOFTWARE-LICENSE-AGREEMENT && \
  mkdir -p ${installPath} && \
  tar xzvfp ${scriptPath}/install.data -C ${installPath} && \
  rm $f && rm -r ${scriptPath} && \
  echo '- SUCCESS installed ----------------------------'
