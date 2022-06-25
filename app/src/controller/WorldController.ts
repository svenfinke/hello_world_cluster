import express, { Application, Request, Response, NextFunction } from "express"

export default class WorldController{
    constructor(app: Application){
        app.get("/", this.helloAction)
        app.get("/bye", this.goodbyeAction)
    }

    helloAction(req: Request, res: Response){
        console.log(req.query.name || "John")
    }

    goodbyeAction(req: Request, res: Response){

    }
}