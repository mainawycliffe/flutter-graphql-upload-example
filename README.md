# Flutter GraphQL Image Uploads

This repo is to demo how to upload files using GraphQL and Flutter. The backend is build using Golang but can be run using docker - no need to install golang.

## Backend

To run the backend, you can use [docker compose](https://docs.docker.com/compose/), simply run `docker-compose up -d --build` at the root directory.

### Upload Image Mutation

To test the server, you can use the built in GraphiQL, whose URL is [http://localhost:8080](http://localhost:8080).

You can run the upload file Mutation below:

```graphql
mutation($file: Upload!) {
  upload(file: $file)
}
```

## Frontend

To run the frontend, change directory to the `flutter` directory, and run `flutter run`. Make sure you have flutter [installed](https://flutter.dev/docs/get-started/install).

### Demo

<p align="center">
    <img src="demo.gif">
</p>

### Accompanying Post

You can find a detailed explanation for the fronted [here](https://codinglatte.com/posts/flutter/flutter-and-graphql-how-to-upload-files/).

## Contributions 

PR are welcome.
