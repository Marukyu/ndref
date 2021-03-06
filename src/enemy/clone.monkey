Strict

Import controller.controller_game
Import enemy
Import point
Import player_class
Import util

Class Clone Extends Enemy

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int, l: Int)
        Super.New()

        Select controller_game.players[0].characterID
            Case Character.Aria
                Self.Init(xVal, yVal, l, "clone", "entities/clone_aria.png")
            Case Character.Bard
                Self.Init(xVal, yVal, l, "clone", "entities/clone_bard.png")
            Case Character.Monk
                Self.Init(xVal, yVal, l, "clone", "entities/clone_monk.png")
            Case Character.Bolt
                Self.Init(xVal, yVal, l, "clone", "entities/clone_bolt.png")
            Case Character.Melody
                Self.Init(xVal, yVal, l, "clone", "entities/clone_melody.png", 19, 23)
            Case Character.Eli
                Self.Init(xVal, yVal, l, "clone", "entities/clone_eli.png", 26, 26)
            Case Character.Dorian
                Self.Init(xVal, yVal, l, "clone", "entities/clone_dorian.png", 25, 26)
            Case Character.Dove
                Self.Init(xVal, yVal, l, "clone", "entities/clone_dove.png", 20, 27)
            Case Character.Coda
                Self.Init(xVal, yVal, l, "clone", "entities/clone_coda.png", 26, 29)
            Case Character.Nocturna
                Self.Init(xVal, yVal, l, "clone", "entities/clone_nocturna.png", 21, 26)
            Case Character.Diamond
                Self.Init(xVal, yVal, l, "clone", "entities/clone_diamond.png", 24, 25)
            Case Character.Reaper
                Self.Init(xVal, yVal, l, "clone", "entities/clone_reaper.png", 19, 25)
            Case Character.Tempo
                Self.Init(xVal, yVal, l, "clone", "entities/clone_tempo.png", 19, 24)
            Case Character.Mary
                Self.Init(xVal, yVal, l, "clone", "entities/clone_mary.png", 19, 25)
            Default
                Self.Init(xVal, yVal, l, "clone")
        End Select

        Self.overrideAttackSound = "cloneAttack"
        Self.overrideDeathSound = "cloneDeath"
    End Method

    Method CanBeLord: Bool()
        Return Not Self.isLord
    End Method

    Method GetMovementDirection: Point()
        Local player1 := controller_game.players[controller_game.player1]
        Local invertedMoveDir := Util.InvertDir(player1.moveLastBeat)

        Return Util.GetPointFromDir(invertedMoveDir)
    End Method

End Class
