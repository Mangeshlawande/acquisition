# acquisition

set install eslint & prettier

npm i eslint @eslint/js prettier eslint-config-prettier eslint-plugin-prettier -D

add new script for eslint

npm run lint
npm run lint:fix

npm run format
npm run format:check

## SETTING up Database

npm install @neondatabase/serverless drizzle-orm

npm i -D drizzle-kit

npm run db:generate
npm run db:migrate

## setup Login and middleware

winston ::A logger library
npm i winston

helmet.js : secure express app with various http headers
npm i helmet

morgan : HTTP request logger middleware for node.js
we use it to monitor traffic , debug request easily (developement)
npm i morgan

npm i cors
where the backend decides , which external domain can make request to our backend

npm i cookie-parser
it will read cookie from incoming request

and make them available in req.cookies
useful for handling session authentication & storing small bits of data
express.json() : parses json data in request body , u can access it direct in body . Its essential for api since most client since both client send data in json format

## implementing Authentication

**Creating routes**:

google httpie

npm i jwt

http client

npm i zod
A backend package for schema validation and type inference in TypeScript. It allows you to define data schemas and validate data against those schemas, ensuring that the data conforms to the expected structure and types.

a valdation library, define schema and parse some data with it ,
will get back a strongly typed , validated result .

bcrypt ::: -->

### Arcjet :::
npm i @arcjet/arcjet
"Arcjet is a lightweight and flexible Node.js framework for building web applications and APIs. It provides a simple and intuitive way to create server-side applications with minimal boilerplate code."   
Bot detection, Rate limiting , Email validation, Attack protection , Data redaction , Caching , Logging , Monitoring , Performance optimization;
