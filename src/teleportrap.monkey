Strict

Import trap

Class TeleportTrap Extends Trap

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int)
        Throw New Throwable()
    End Method

End Class