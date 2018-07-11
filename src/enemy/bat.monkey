'Strict

Import gui.controller_game
Import gui.controller_level_editor
Import enemy
Import entity
Import level
Import logger
Import point
Import shrine
Import util

Class Bat Extends Enemy

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int, l: Int)
        Super.New()

        Select l
            Case 1
                If Shrine.warShrineActive Then l = 2
            Case 2,
                 4
            If Util.IsCharacterActive(Character.Bolt) Or
               Util.AreAriaOrCodaActive()
                If Not Level.isBeastmaster And
                   controller_game.currentLevel <> -3000
                    l = 1
                Else If l = 2 And
                        Not Level.isTrainingMode And
                        Not Level.isHardcoreMode And
                        controller_game.currentLevel <> -3000 And
                        ControllerLevelEditor.playingLevel = -1
                    l = 1
                End If
            End If
        End Select

        Self.Init(xVal, yVal, l, "bat", "", -1, -1)

        Self.overrideAttackSound = "batAttack"
        Self.overrideHitSound = "batHit"
        Self.overrideDeathSound = "batDeath"
    End Method

    Method GetMovementDirection: Point()
        Debug.TraceNotImplemented("Bat.GetMovementDirection()")
    End Method

    Method Hit: Bool(damageSource: String, damage: Int, dir: Int, hitter: Entity, hitAtLastTile: Bool, hitType: Int)
        Debug.TraceNotImplemented("Bat.Hit(String, Int, Int, Entity, Bool, Int)")
    End Method

    Method Update: Void()
        If Self.lastX > Self.x
            Self.image.FlipX(True, True)
        Else If Self.x > Self.lastX
            Self.image.FlipX(False, True)
        End If

        Super.Update()
    End Method

End Class
