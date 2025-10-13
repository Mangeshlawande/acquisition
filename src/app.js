import express from 'express';
import logger from '#config/logger.js';
import helmet from 'helmet';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import morgan from 'morgan';
import authRouter from '#routes/auth.routes.js';
import securityMiddleware from '#middleware/security.middleware.js';

const app = express();

app.use(helmet());
app.use(cors());
app.use(securityMiddleware)
app.use(express.json()); //  allow to pass json object through its request
app.use(cookieParser());

app.use(express.urlencoded({ extended: true })); // built-in ,allows to parse incoming request with url encoded pillers .

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

app.use('/api/auth', authRouter);

app.use(
  morgan('combined', {
    stream: { write: message => logger.info(message.trim()) },
  })
);

app.get('/', (req, res) => {
  logger.info('Hello from Acquisitions ! ');
  res.status(200).send('Hello from Acquisitions! ');
});

app.get('/api', (req, res) => {
  res.status(200).send({ message: 'Acquisitions! api is running ' });
});

export default app;
