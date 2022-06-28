import express, { Application, Request, Response, NextFunction } from "express"

export default class WorldController{
    constructor(app: Application){
        app.get("/", this.helloAction)
        app.get("/bye", this.goodbyeAction)
    }

    helloAction(req: Request, res: Response){
        let name = req.query.name || "John"
        res.send("Hello " + name + "!")
    }

    goodbyeAction(req: Request, res: Response){
        let name = req.query.name || "John"
        res.send("Goodbye " + name + "!")
    }
}