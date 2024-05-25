FROM renatoexpert/flutter:2.0.6 as load
WORKDIR /app
COPY . .
RUN flutter pub get

FROM load as doctor
CMD flutter doctor -v

FROM load as web_build
#RUN flutter build web --release --web-renderer canvaskit
RUN flutter build web --profile

FROM scratch as web_package
COPY --from=web_build /app/build/web /web

FROM python:3.11.9-alpine3.19 as web_deploy
EXPOSE 8080
WORKDIR /web
COPY --from=web_package /web .
CMD python3 -m http.server --bind 0.0.0.0 8080

