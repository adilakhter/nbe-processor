FROM ubuntu:14.04

# adding ppa to install ruby 2.0 
# RUN add-apt-repository ppa:brightbox/ruby-ng

# installing ruby 
RUN apt-get install -y ruby2.0

# make sure apt is up to date
RUN apt-get update

# install nodejs and npm
RUN apt-get install -y nodejs npm

# Bundle app source
COPY ./src /src

# Install app dependencies
RUN cd /src; npm install

# EXPOSE  8080

CMD ["node", "/src/ nbe-processor-runner.js"]