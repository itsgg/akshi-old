## Mac OS

### Install dependencies

    brew install imagemagick
    brew install graphicsmagick
    brew install poppler
    brew install ghostscript
    brew install tesseract
    brew install redis
    brew install ffmpeg
    brew install yamdi
    brew install nodejs

### Chrome Driver

Install ChromeDriver https://code.google.com/p/selenium/wiki/ChromeDriver

### Libre Office

Install libreoffice from http://www.libreoffice.org/download/

### Nginx and Passenger

Install nginx http://nginx.com/ & mod_passenger

#### Nginx configuration

    worker_processes  1;

    events {
        worker_connections  1024;
    }

    http {
        passenger_root /usr/local/Cellar/ruby/1.9.3-p385/lib/ruby/gems/1.9.1/gems/passenger-3.0.19;
        passenger_ruby /usr/local/Cellar/ruby/1.9.3-p385/bin/ruby;
        include       mime.types;
        default_type  application/octet-stream;
        sendfile        on;
        keepalive_timeout  65;
        client_max_body_size 200M;
        server {
            server_name  localhost;
            root /Users/gg/Work/Akshi/web/public;
            passenger_enabled on;
            rails_env development;
        }
    }

    rtmp {
        server {
            listen 1935;
            chunk_size 4000;
            ping 10s;
            application live {
                live on;
                wait_key on;
                wait_video on;
            }

            application vod {
                play /Users/gg/Work/Akshi/web/data;
            }
        }
    }


## Linux Setup

### Setup users

    groupadd admin
    adduser deployer --ingroup admin
    su deployer
    sudo adduser deployer sudo
    sudo apt-get update
    sudo apt-get upgrade


### Ruby & Rails

    sudo apt-get install build-essential zlib1g-dev git-core libmysqlclient-dev mysql-server libxslt-dev libxml2-dev sqlite3 libsqlite3-dev pkg-config
    cd
    git clone git://github.com/sstephenson/rbenv.git .rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
    echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
    source ~/.bash_profile
    git clone https://github.com/sstephenson/ruby-build.git
    cd ruby-build
    sudo ./install.sh
    rbenv install 1.9.3-p194
    rbenv rehash
    rbenv global 1.9.3-p194
    rbenv rehash


#### YASM

    wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
    tar -xvf yasm-1.2.0.tar.gz
    cd yasm-1.2.0
    ./configure
    make
    sudo make install
    cd ..

#### FFMPEG

    git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
    cd ffmpeg
    ./configure
    make
    sudo make install
    cd ..

#### FAAC

    wget http://kaz.dl.sourceforge.net/project/faac/faac-src/faac-1.28/faac-1.28.tar.bz2
    tar -xvf faac-1.28.tar.bz2
    cd faac-1.28
    ./configure
    Comment out
    // char *strcasestr(const char *haystack, const char *needle);
    in common/mp4v2/mpeg4ip.h line 126
    make
    sudo make install
    cd..

#### LAME

    wget http://kaz.dl.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
    tar -xvf lame-3.99.5.tar.gz
    cd lame-3.99.5
    ./configure
    make
    sudo make install
    cd ..

#### x264

    git clone git://git.videolan.org/x264.git x264
    cd x264
    ./configure --enable-static --enable-shared
    make
    sudo make install
    cd ..

#### Recompile FFMPEG

    cd ffmpeg
    make clean
    ./configure --enable-gpl --enable-nonfree --enable-pthreads
        --enable-libx264 --enable-libfaac --enable-libmp3lame
    make
    sudo make install


    add /usr/local/lib to /etc/ld.so.conf
    ldconfig

#### Nginx

    gem install passenger
    passenger-install-nginx-module

#### Add Rtmp Module nginx

    --add-module=../nginx-rtmp-module/
    --add-module=../nginx-rtmp-module/ --with-debug --with-ld-opt="-L /usr/local/lib"

#### Configuration (Development)

    worker_processes 1;
    events {
        worker_connections 1024;
    }

    http {
        passenger_root /home/deployer/.rbenv/versions/1.9.3-p194/lib/ruby/gems/1.9.1/gems/passenger-3.0.17;
        passenger_ruby /home/deployer/.rbenv/versions/1.9.3-p194/bin/ruby;

        include mime.types;
        default_type application/octet-stream;
        sendfile on;
        keepalive_timeout 65;
        client_max_body_size 2000M;

        types {
            video/ogg .ogv;
            video/mp4 .m4v;
            video/webm .webm;
            audio/mpeg .mp3;
            audio/ogg .ogg;
            audio/mp4 .m4a;
        }

        server {
            listen 3000;
            server_name localhost;
            passenger_enabled on;
            root /Users/gg/Work/Akshi/akshi/public;
            rails_env development;
        }

        rtmp {
            server {
                listen 1935;
                chunk_size 4000;
                ping 10s;
                application live {
                    live on;
                }

                application vod {
                    play /Users/gg/Work/Akshi/akshi/data;
                }
            }
        }
    }

#### Nginx Configuration (Production)

    user  deployer admin;
    worker_processes  1;

    events {
      worker_connections  1024;
    }

    http {
      passenger_root /home/deployer/.rbenv/versions/1.9.3-p194/lib/ruby/gems/1.9.1/gems/passenger-3.0.17;
      passenger_ruby /home/deployer/.rbenv/versions/1.9.3-p194/bin/ruby;

      include mime.types;
      default_type application/octet-stream;
      sendfile on;
      keepalive_timeout 65;
      client_max_body_size 300M;

      server {
        listen 80;
        rewrite ^(.*) https://$host$1 permanent;
      }

      server {
        listen 443;
        server_name akshi.com;
        root /u/apps/akshi/current/public;
        passenger_enabled on;
        ssl on;
        ssl_certificate /u/apps/akshi/shared/keys/akshi.pem;
        ssl_certificate_key /u/apps/akshi/shared/keys/akshi.key;
        if ($host = 'www.akshi.com' ) {
          rewrite  ^/(.*)$  https://akshi.com/$1  permanent;
        }

        proxy_set_header  X-Sendfile-Type X-Accel-Redirect;
        passenger_pass_header X-Accel-Redirect;
        proxy_set_header  X-Accel-Mapping /system/=/paperclip/;
        passenger_set_cgi_param HTTP_X_ACCEL_MAPPING /system/=/paperclip/;
        proxy_set_header  X-Accel-Mapping /u/apps/akshi/current/data/=/data/;
        passenger_set_cgi_param HTTP_X_ACCEL_MAPPING /u/apps/akshi/current/data/=/data/;

        location /paperclip {
          root /u/apps/akshi/current/public/system;
          internal;
        }

        location /data {
          root /u/apps/akshi/current;
          internal;
        }

        location ~ ^/(assets|images|javascripts|stylesheets|swfs)/ {
          gzip_static on;
          expires max;
          add_header Cache-Control public;
          add_header Last-Modified "";
          add_header ETag "";

          open_file_cache max=1000 inactive=500s;
          open_file_cache_valid 600s;
          open_file_cache_errors on;

          break;
        }
      }
    }

    rtmp {
        server {
            listen 1935;
            chunk_size 4000;
            ping 10s;
            application live {
                live on;
                wait_key on;
                wait_video on;
            }

            application vod {
                play /u/apps/akshi/current/data;
            }
        }
    }


### Bundler

    gem install bundle
    cp .bash_profile .bashrc

### Openoffice headless

    sudo apt-get install libreoffice-core libreoffice-writer libreoffice-calc libreoffice-impress

### Others

    sudo apt-get install imagemagick graphicsmagick poppler-utils tesseract-ocr redis-server libssl-dev libopenssl-ruby libcurl4-openssl-dev nodejs openjdk-7-jre-headless  python-software-properties yamdi

### SSL certificate

    openssl req -new -newkey rsa:2048 -nodes -keyout akshi.co.key -out akshi.co.csr


