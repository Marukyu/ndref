'Strict

Import monkey.list
Import controller.controller_game
Import enemy
Import enemy.crate
Import level
Import trap
Import trap.bombtrap
Import trap.bouncetrap
Import trap.confusetrap
Import trap.firetrap
Import trap.scattertrap
Import trap.teleporttrap
Import trap.trapdoor
Import trap.travelrune
Import chest
Import item
Import logger
Import point
Import salechest
Import saleitem
Import shrine
Import tile
Import xml

Class LevelObject

    Function _EditorFix: Void() End

    Method New(num: Int, music: Int, boss: Int, loadFromCurrent: Bool, fromXML: XMLNode)
        Self.levelNum = num
        Self.musicType = music
        Self.bossNum = boss

        If Not loadFromCurrent
            If fromXML <> Null
                Self.musicType = fromXML.GetAttribute("music", 0)
                Self.bossNum = fromXML.GetAttribute("bossNum", -1)

                Local tilesNode := fromXML.GetChild("tiles")
                Local tileNodes := tilesNode.GetChildren("tile")
                For Local tileNode := EachIn tileNodes
                    Self.tiles.AddLast(New TileObject(tileNode))
                End For

                Local trapsNode := fromXML.GetChild("traps")
                Local trapNodes := trapsNode.GetChildren("trap")
                For Local trapNode := EachIn trapNodes
                    Self.traps.AddLast(New trapObject(trapNode))
                End For

                Local enemiesNode := fromXML.GetChild("enemies")
                Local enemyNodes := enemiesNode.GetChildren("enemy")
                For Local enemyNode := EachIn enemyNodes
                    Self.enemies.AddLast(New enemyObject(enemyNode))
                End For

                Local itemsNode := fromXML.GetChild("items")
                Local itemNodes := itemsNode.GetChildren("item")
                For Local itemNode := EachIn itemNodes
                    Self.items.AddLast(New itemObject(itemNode))
                End For

                Local chestsNode := fromXML.GetChild("chests")
                Local chestNodes := chestsNode.GetChildren("chest")
                For Local chestNode := EachIn chestNodes
                    Self.chests.AddLast(New chestObject(chestNode))
                End For

                Local cratesNode := fromXML.GetChild("crates")
                Local crateNodes := cratesNode.GetChildren("crate")
                For Local crateNode := EachIn crateNodes
                    Self.crates.AddLast(New crateObject(crateNode))
                End For
            End If
        Else
            For Local tilesOnX := EachIn Level.tiles
                For Local tileNode := EachIn tilesOnX.Value()
                    Local tile := tileNode.Value()
                    Local tileObj := New TileObject(tile.x, tile.y, tile.type, tile.tilesetOverride, tile.isCracked, tile.HasTorch())
                    Self.tiles.AddLast(tileObj)
                End For
            End For

            For Local trap := EachIn Trap.trapList
                Local trapObj := New TrapObject(trap.x, trap.y, trap.trapType)

                Select trap.trapType
                    Case TrapType.BounceTrap
                        Local bounceTrap := BounceTrap(trap)
                        If bounceTrap.isRotatingCW Or bounceTrap.isRotatingCCW
                            trapObj.subtype = TrapType.BombTrap
                        End If
                    Case TrapType.TravelRune
                        Local travelRune := TravelRune(trap)
                        trapObj.subtype = travelRune.runeType
                    Case TrapType.FireTrap
                        Local fireTrap := FireTrap(trap)
                        trapObj.subtype = fireTrap.fireDir
                End Select

                Self.traps.AddLast(trapObj)
            End For

            For Local enemy := EachIn Enemy.enemyList
                If Crate(enemy) = Null
                    Local enemyObj := New EnemyObject(enemy.x, enemy.y, enemy.enemyType, enemy.currentMoveDelay, enemy.isLord)
                    Self.enemies.AddLast(enemyObj)
                End If
            End For

            For Local item := EachIn Item.pickupList
                Local itemObj := New ItemObject(item.x, item.y, item.itemType, item.singleChoiceItem, 0, 0)

                If item.hasBloodCost
                    Local saleItem := SaleItem(item)
                    itemObj.bloodCost = saleItem.bloodCost
                Else If item.isSaleItem
                    Local saleItem := SaleItem(item)
                    itemObj.saleCost = saleItem.cost
                End If

                Self.items.AddLast(itemObj)
            End For

            For Local chest := EachIn Chest.chestList
                Local chestObj := New ChestObject(chest.x, chest.y, chest.chestColor, chest.contents, chest.singleChoiceChest, chest.secretChest, 0)

                If chest.saleChest
                    Local saleChest := SaleChest(chest)
                    chestObj.saleCost = saleChest.cost
                End If

                Self.chests.AddLast(chestObj)
            End For

            For Local crate := EachIn Crate.crateList
                Local crateObj := New CrateObject(crate.x, crate.y, crate.enemyType, crate.contents)
                Self.crates.AddLast(crateObj)
            End For

            For Local shrine := EachIn Shrine.shrineList
                Local shrineObj := New ShrineObject(shrine.x, shrine.y, shrine.type)
                Self.shrines.AddLast(shrineObj)
            End For
        End If
    End Method

    Field levelNum: Int = 1
    Field musicType: Int = 0
    Field bossNum: Int = -1
    Field tiles: List<TileObject> = New List<TileObject>()
    Field traps: List<TrapObject> = New List<TrapObject>()
    Field enemies: List<EnemyObject> = New List<EnemyObject>()
    Field items: List<ItemObject> = New List<ItemObject>()
    Field chests: List<ChestObject> = New List<ChestObject>()
    Field crates: List<CrateObject> = New List<CrateObject>()
    Field shrines: List<ShrineObject> = New List<ShrineObject>()

    Method CreateMap: Void()
        For Local tileObj := EachIn tiles
            Local tile := Level.PlaceTileRemovingExistingTiles(tileObj.x, tileObj.y, tileObj.type, False, tileObj.zone, False)

            If tileObj.cracked Then tile.BecomeCracked()
            If tileObj.torch Then tile.AddTorch()

            Select tile.type
                Case TileType.Stairs
                    Local exitKey := New Point(tile.x, tile.y)
                    Local exitValue := New Point(LevelType.NextLevel, currentZone)
                    Level.exits.Set(exitKey, exitValue)
                Case TileType.LockedStairsMiniboss
                    Level.CreateExit(tile.x, tile.y)
            End Select
        End For

        Tile.GenerateWireConnections()

        For Local trapObj := EachIn traps
            Select trapObj.type
                Case TrapType.BounceTrap
                    New BounceTrap(trapObj.x, trapObj.y, trapObj.subtype)
                Case TrapType.SpikeTrap
                    New SpikeTrap(trapObj.x, trapObj.y)
                Case TrapType.TrapDoor
                    New TrapDoor(trapObj.x, trapObj.y)
                Case TrapType.ConfuseTrap
                    New ConfuseTrap(trapObj.x, trapObj.y)
                Case TrapType.TeleportTrap
                    New TeleportTrap(trapObj.x, trapObj.y)
                Case TrapType.SlowDownTrap
                    New SlowDownTrap(trapObj.x, trapObj.y)
                Case TrapType.SpeedUpTrap
                    New SpeedUpTrap(trapObj.x, trapObj.y)
                Case TrapType.BombTrap
                    New BombTrap(trapObj.x, trapObj.y)
                Case TrapType.ScatterTrap
                    New ScatterTrap(trapObj.x, trapObj.y)
                Case TrapType.FireTrap
                    New FireTrap(trapObj.x, trapObj.y, trapObj.subtype, False)
                Case TrapType.TravelRune
                    If Not Level.isLevelEditor
                        Level.secretAtX = trapObj.x
                        Level.secretAtY = trapObj.y
                        Level.AddSpecialRoom(trapObj.subtype, False)
                    End If

                    New TravelRune(trapObj.x, trapObj.y, Level.specialRoomEntranceX, Level.specialRoomEntranceY, trapObj.subtype)
            End Select
        End For

        For Local enemyObj := EachIn enemies
            Local enemy := Enemy.MakeEnemy(enemyObj.x, enemyObj.y, enemyObj.type)

            If enemyObj.beatDelay <> -1
                enemy.currentMoveDelay = enemyObj.beatDelay
            End If

            If enemyObj.lord
                enemy.MakeLord()
            End If

            If enemy.isMiniboss
                enemy.isStairLockingMiniboss = True
            End If
        End For

        For Local itemObj := EachIn items
            Local item: Item

            If itemObj.bloodCost <= 0.0
                If itemObj.saleCost <= 0
                    item = New Item(itemObj.x, itemObj.y, itemObj.type, False, -1, False)
                Else
                    item = New SaleItem(itemObj.x, itemObj.y, itemObj.type, False, Null, -1.0, Null)
                End If
            Else
                item = New SaleItem(itemObj.x, itemObj.y, itemObj.type, True, Null, -1.0, Null)
            End If

            item.singleChoiceItem = itemObj.singleChoice
        End For

        For Local chestObj := EachIn chests
            Local chest: Chest

            If chestObj.saleCost <= 0
                chest = New Chest(chestObj.x, chestObj.y, chestObj.contents, chestObj.hidden, False, chestObj.hidden, chestObj.color)
            Else
                chest = New SaleChest(chestObj.x, chestObj.y, chestObj.contents, chestObj.hidden, False, chestObj.hidden, chestObj.color)
            End If

            chest.singleChoiceChest = chestObj.singleChoice
        End For

        For Local crateObj := EachIn crates
            New Crate(crateObj.x, crateObj.y, crateObj.type, crateObj.contents)
        End For

        For Local shrineObj := EachIn shrines
            New Shrine(shrineObj.x, shrineObj.y, shrineObj.type, Null, False, False)
        End For
    End Method

    Method ToXML: XMLDoc()
        Debug.TraceNotImplemented("LevelObject.ToXML()")
    End Method

End Class

Class TileObject

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int, type: Int, zone: Int, cracked: Bool, torch: Bool)
        Self.x = xVal
        Self.y = yVal
        Self.type = type
        Self.zone = zone
        Self.cracked = cracked
        Self.torch = torch
    End Method

    Method New(fromXML: XMLNode)
        Debug.TraceNotImplemented("TileObject.New(XMLNode)")
    End Method

    Field x: Int
    Field y: Int
    Field type: Int
    Field zone: Int
    Field cracked: Bool
    Field torch: Bool

    Method AddToXML: Void(xml: XMLNode)
        Debug.TraceNotImplemented("TileObject.AddToXML(XMLNode)")
    End Method

End Class

Class TrapObject

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int, type: Int)
        Self.x = xVal
        Self.y = yVal
        Self.type = type
    End Method

    Method New(fromXML: XMLNode)
        Debug.TraceNotImplemented("TrapObject.New(XMLNode)")
    End Method

    Field x: Int
    Field y: Int
    Field type: Int
    Field subtype: Int = -1

    Method AddToXML: Void(xml: XMLNode)
        Debug.TraceNotImplemented("TrapObject.AddToXML(XMLNode)")
    End Method

End Class

Class EnemyObject

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int, type: Int, beatDelay: Int, lord: Bool)
        Self.x = xVal
        Self.y = yVal
        Self.type = type
        Self.beatDelay = beatDelay
        Self.lord = lord
    End Method

    Method New(fromXML: XMLNode)
        Debug.TraceNotImplemented("EnemyObject.New(XMLNode)")
    End Method

    Field x: Int
    Field y: Int
    Field type: Int
    Field beatDelay: Int = -1
    Field lord: Bool

    Method AddToXML: Void(xml: XMLNode)
        Debug.TraceNotImplemented("EnemyObject.AddToXML(XMLNode)")
    End Method

End Class

Class ItemObject

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int, type: String, singleChoice: Bool, saleCost: Int, bloodCost: Float)
        Self.x = xVal
        Self.y = yVal
        Self.type = type
        Self.singleChoice = singleChoice
        Self.saleCost = saleCost
        Self.bloodCost = bloodCost
    End Method

    Method New(fromXML: XMLNode)
        Debug.TraceNotImplemented("ItemObject.New(XMLNode)")
    End Method

    Field x: Int
    Field y: Int
    Field type: String
    Field singleChoice: Bool
    Field saleCost: Int
    Field bloodCost: Float

    Method AddToXML: Void(xml: XMLNode)
        Debug.TraceNotImplemented("ItemObject.AddToXML(XMLNode)")
    End Method

End Class

Class ChestObject

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int, color: Int, contents: String, singleChoice: Bool, hidden: Bool, saleCost: Int)
        Self.x = xVal
        Self.y = yVal
        Self.color = color
        Self.contents = contents
        Self.singleChoice = singleChoice
        Self.hidden = hidden
        Self.saleCost = saleCost
    End Method

    Method New(fromXML: XMLNode)
        Debug.TraceNotImplemented("ChestObject.New(XMLNode)")
    End Method

    Field x: Int
    Field y: Int
    Field color: Int
    Field contents: String
    Field singleChoice: Bool
    Field hidden: Bool
    Field saleCost: Int

    Method AddToXML: Void(xml: XMLNode)
        Debug.TraceNotImplemented("ChestObject.AddToXML(XMLNode)")
    End Method

End Class

Class CrateObject

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int, type: Int, contents: String)
        Self.x = xVal
        Self.y = yVal
        Self.type = type
        Self.contents = contents
    End Method

    Method New(fromXML: XMLNode)
        Debug.TraceNotImplemented("CrateObject.New(XMLNode)")
    End Method

    Field x: Int
    Field y: Int
    Field type: Int
    Field contents: String

    Method AddToXML: Void(xml: XMLNode)
        Debug.TraceNotImplemented("CrateObject.AddToXML(XMLNode)")
    End Method

End Class

Class ShrineObject

    Function _EditorFix: Void() End

    Method New(xVal: Int, yVal: Int, type: Int)
        Self.x = xVal
        Self.y = yVal
        Self.type = type
    End Method

    Method New(fromXML: XMLNode)
        Debug.TraceNotImplemented("ShrineObject.New(XMLNode)")
    End Method

    Field x: Int
    Field y: Int
    Field type: Int

    Method AddToXML: Void(xml: XMLNode)
        Debug.TraceNotImplemented("ShrineObject.AddToXML(XMLNode)")
    End Method

End Class
