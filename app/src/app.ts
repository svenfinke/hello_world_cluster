import express, { Application, Request, Response, NextFunction } from "express"
import bodyParser from "body-parser"
import WorldController from "./controller/WorldController"
import helmet from "helmet"

// deepcode ignore UseCsurfForExpress: <please specify a reason of ignoring this>
const app: Application = express()

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

// Use helmet as a best-practice to improve security (as considered by SNYK)
app.use(helmet())

new WorldController(app);

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`server is running on PORT ${PORT}`)
})