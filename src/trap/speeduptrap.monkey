'Strict

Import entity
Import logger
Import trap

Class SpeedUpTrap Extends Trap

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int)
        Super.New(xVal, yVal, TrapType.SpeedUpTrap)

        Self.xOff = 5.0
        Self.yOff = 15.0
        Self.image = New Sprite("traps/speeduptrap.png", 14, 16, 4)
        Self.image.SetZ(-995.0)
    End Method

    Field speedUpStartBeat: Int = -1
    Field currentMusicSpeed: Float = 1.0

    Method Trigger: Void(ent: Entity)
        Debug.TraceNotImplemented("SpeedUpTrap.Trigger(Entity)")
    End Method

    Method Update: Void()
        Debug.TraceNotImplemented("SpeedUpTrap.Update()")
    End Method

End Class
