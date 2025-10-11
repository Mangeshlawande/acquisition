import express from 'express';
import logger from '#config/logger.js';
import helmet from 'helmet';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import morgan from 'morgan';

const app = express();

app.use(helmet());
app.use(cors())
app.use(express.json()) //  allow to pass json object through its request 
app.use(cookieParser())

app.use(express.urlencoded({ extended: true }))// built-in ,allows to parse incoming request with url encoded pillers .
app.use(morgan('combined', { stream: { write: (message) => logger.info(message.trim()) } }));



app.get('/', (req, res) => {
  logger.info("Hello from Acquisitions ! ")
  res.status(200).send('Hello from Acquisitions! ');
});

export default app;
