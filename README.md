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

helmet.js : secure express app with various  http headers 
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