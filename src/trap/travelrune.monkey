'Strict

Import entity
Import logger
Import trap

Class TravelRune Extends Trap

    Function TravelTo: Void(ent: Object, toX: Int, toY: Int)
        Debug.TraceNotImplemented("TravelRune.TravelTo(Object, Int, Int)")
    End Function

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int, toX: Int, toY: Int, runeNum: Int)
        Super.New(xVal, yVal, TrapType.TravelRune)

        Self.xOff = -1.0
        Self.yOff = 12.0
        Self.isRune = True
        Self.runeType = runeNum
        Self.travelToX = toX
        Self.travelToY = toY

        Self.image = New Sprite("traps/travelrune.png", 24, 24, 4)
        Self.image.SetZ(-995.0)
    End Method

    Field runeType: Int = TravelRuneType.Transmogrifier
    Field travelToX: Int
    Field travelToY: Int
    Field retractCounter: Int

    Method Trigger: Void(ent: Entity)
        Debug.TraceNotImplemented("TravelRune.Trigger(Entity)")
    End Method

    Method Update: Void()
        If Self.retractCounter > 0
            Self.retractCounter -= 1
            If Self.retractCounter = 0
                Self.triggered = False    
            End If
        End If

        Self.image.SetFrame(1)

        If Self.triggered
            Self.image.SetFrame(0)
        End If

        Super.Update()
    End Method

End Class

Class TravelRuneType

    Const Transmogrifier: Int = 1
    Const Arena: Int = 2
    Const BloodShop: Int = 3
    Const GlassShop: Int = 4
    Const FoodShop: Int = 5
    Const Conjurer: Int = 6
    Const Shriner: Int = 7
    Const Pawnbroker: Int = 8

End Class
