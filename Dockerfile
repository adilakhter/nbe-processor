FROM ubuntu:14.04

# adding ppa to install ruby 2.0 
# RUN add-apt-repository ppa:brightbox/ruby-ng

# make sure apt is up to date
RUN apt-get update

# installing ruby 
RUN apt-get install -y ruby2.0 wget

# install node and npm
RUN apt-get install -y node npm

# downloading rubygems
RUN wget https://rubygems.org/rubygems/rubygems-2.4.8.tgz

# extracting rubygems 
RUN tar xvf rubygems-2.4.8.tgz

# CD To Ruby GEM 
RUN cd rubygems-2.4.8; ruby setup.rb

# installing REDIS gem 
RUN gem install redis

# Bundle app source
COPY ./src /src

# Install app dependencies
RUN cd /src

