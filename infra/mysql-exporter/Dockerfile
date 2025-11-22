FROM prom/mysqld-exporter:latest

# Create a valid but empty .my.cnf to prevent the warning
RUN printf "[client]\nuser=root\npassword=root\nhost=mysql\n" > /tmp/my.cnf && \
    cat /tmp/my.cnf

ENTRYPOINT ["/bin/mysqld_exporter", "--config.my-cnf=/tmp/my.cnf"]
CMD ["--web.listen-address=:9104"]
