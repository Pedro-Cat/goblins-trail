// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser


// Cria a struct do Player
struct Player {
    var life = 100
    var damage = 20
    var meters = 0
    var kills = 0
    var isDefending = false
}

// Cria a struct do Goblin
struct Goblin {
    var life = 100
    var damage = 5
    var isReady = false
    var isAttacking = false
}

// Declara variáveis globais que serão necessárias
var enter = "000"
var count = 0

var quit = false
var inCombat = false

var input = ""

var player = Player()
var goblin = Goblin()

var turnTime: UInt32 = 800000
var gobDamage = 5
var gobDamageWhileDefending = 1
var gobChanceAttack = 40
var gobLife = 100

// main
@main
struct GoblinsTrail: ParsableCommand {
    
    static var configuration = CommandConfiguration(
            abstract: "Goblin's Trail",
            usage: """
                    got [OPTIONS]
                    """,
            discussion: """
                    This game is an ASCII RPG that operates through commands in the terminal.
                    Destroy all the goblins in your path.
                    
                    Q - Quit game
                    X - Attack/Forward
                    Z - Defence

                    WARNING:
                    Change your terminal background to white, your text color to black and
                    your line spacing to 0,782 for a better game experience.
                    Terminal >> Settings >> Text >> Font >> Change
                    """)
    
    
    @Flag(name: .shortAndLong, help: "Set easy mode (u w u)")
    var baby: Bool = false
    
    @Flag(name: .shortAndLong, help: "Set medium mode (⌐■_■)")
    var medium: Bool = false
    
    @Flag(name: .shortAndLong, help: "Set hard mode ༼ ༎ຶ ෴ ༎ຶ༽")
    var nightmare: Bool = false
    
    // TODO: Colocar Swiftlint
    
    mutating func run() throws {
        
        
        if baby {
            
            turnTime = 1500000
            gobDamage = 3
            gobDamageWhileDefending = 0
            gobChanceAttack = 20
            gobLife = 80
            medium = false
            nightmare = false
            
            
        }
        if medium {
            
            baby = false
            nightmare = false
        }
        
        if nightmare {
            
            turnTime = 500000
            gobDamage = 10
            gobChanceAttack = 60
            gobLife = 100
            baby = false
            medium = false
        }
        
        
        // Código da tela inicial
        // Cria uma task assincrona para rodar os prints de forma "animada"
        if #available(macOS 10.15, *) {
            Task {
                while enter == "000" {
                    printBorder()
                    print(menu)
                    printBorder()
                    sleep(1)
                    if enter != "000" {
                        break
                    }
                    printBorder()
                    print(menu2)
                    printBorder()
                    sleep(1)
                }
            }
        } else {
            // Fallback on earlier versions
        }
        // Espera a confirmação do usuário no thread principal
        enter = readLine() ?? "000"

        // Início do loop de jogo
        while !quit {
            // Declara o player no while mais externo para caso de game over e o
            // usuário queira continuar jogando, assim, resetando o player
            player = Player()
            
            // Início do loop médio
            while !quit && player.life > 0 {
                // Início da parte de animação de caminhada do jogador
                let walks = [walking1, walking2, walking3]
                let idles = [idle1, idle2, idle3]
                
                input = String((count+1)) + String((count+1)) + String((count+1))
                
                if #available(macOS 10.15, *) {
                    Task {
                        let taskID = String((count+1)) + String((count+1)) + String((count+1))
                        while input == taskID {
                            printHud(player)
                            print(walks[count])
                            sleep(1)
                            if input != taskID {
                                break
                            }
                            printHud(player)
                            print(idles[count])
                            sleep(1)
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
               
                // Fim da parte de animação de caminhada do jogador
                
                // Recebe um input e apartir dele ações são tomadas
                input = readLine()?.lowercased() ?? "999"
                
                if input == "" || (input.last! != "x" && input.last! != "q") {
                    input = String((count+2)) + String((count+2)) + String((count+2))
                } else {
                    count += 1
                }
                
                if count > 2 {
                    count = 0
                }
                // Sai do loop médio
                if input.last! == "q" {
                    quit = true
                }
                
                // O jogador anda
                if input.last! == "x" {
            
                    player.meters += 1
                    
                    // Chance de 20% de achar um goblin a cada passo
                    if Int.random(in: 1...10) <= 2 {
                        // Caso ache, declara o goblin, printa o mesmo e inicia o combate
                        goblin = Goblin(life: gobLife, damage: gobDamage)
                        
                        printHud(player)
                        print(gob)
                        
                        inCombat = true
                        // Reseta input que pode estar "sujo" das andadas do jogador
                        input = "000"
                        
                        // Cria task assincrona que será o jogo de fato, animações e
                        // cálculos seram feitas aqui dentro, de forma assincrona
                        if #available(macOS 10.15, *) {
                            Task {
                                // Inicia loop de combate, que acaba quando quita, sai do combate ou o goblin morre
                                while !quit && inCombat && goblin.life > 0 {
                                    // Fluxo de execução caso o goblin esteja preparado pro ataque
                                    if goblin.isReady {
                                        // Se o jogador estiver defendendo
                                        if player.isDefending {
                                            player.life -= gobDamageWhileDefending
                                            printHud(player)
                                            print(gobAttackSwordless)
                                            usleep(300000)
                                            printHud(player)
                                            print(gobSwordless)
                                            // Senão
                                        } else {
                                            player.life -= goblin.damage
                                            printHud(player)
                                            print(gobAttack)
                                            usleep(300000)
                                            printHud(player)
                                            print(gob)
                                        }
                                        // Seta que o goblin não esta mais preparado
                                        goblin.isReady = false
                                    }
                                    
                                    // Caso o player ou o goblin esteja com 0 ou menos de vida
                                    if player.life <= 0 || goblin.life <= 0 {
                                        // Encerra o combate e sai do loop
                                        inCombat = false
                                        break
                                    }
                                    // 40% de chance do goblin preparar um ataque
                                    if Int.random(in: 1...100) <= gobChanceAttack {
                                        printHud(player)
                                        if player.isDefending {
                                            print(gobReadySwordless)
                                        } else {
                                            print(gobReady)
                                        }
                                        goblin.isReady = true
                                    }
                                    
                                    // Delay para o jogador ter um tempo para pensar
                                    usleep(turnTime)
                                    
                                    // Sair do loop de combate e do médio
                                    if input.last! == "q" {
                                        quit = true
                                    }
                                    // Jogador ataca com x ou apertando return sem estar defendendo
                                    if input.last == "x" || (input == "" && !player.isDefending) {
                                        // Para de defender
                                        player.isDefending = false
                                        // Se o goblin não estiver preparado, o jogador acertará o golpe
                                        if !goblin.isReady {
                                            printHud(player)
                                            print(gobSlash)
                                            goblin.life -= player.damage
                                            usleep(300000)
                                            printHud(player)
                                            print(gob)
                                            // Senão, o o goblin o acerta
                                        } else {
                                            printHud(player)
                                            print(gobAttack)
                                        }
                                    }
                                    
                                    //Verificar morte Goblin
                                    if goblin.life <= 0 {
                                        player.kills += 1
                                        printHud(player)
                                        print(slayed)
                                        sleep(1)
                                        inCombat = false
                                        // analisar essa parte do codigo e talvez colocar um count = 0 e retirar esses prints abaixo
                                        printHud(player)
                                        print(walking1)
                                        break
                                    }
                                    // Jogador defende
                                    if input.last! == "z" {
                                        printHud(player)
                                        if goblin.isReady {
                                            print(gobReadySwordless)
                                        } else {
                                            print(gobSwordless)
                                        }
                                        player.isDefending = true
                                    }
                                    // Reset de input, apenas para ficar mais seguro contra bugs
                                    input = "000"
                                }
                            }
                        } else {
                            // Fallback on earlier versions
                        }
                        // Loop do input no thread principal, funciona paralelamente com
                        // o loop que está dentro da task assincrona passada
                        while !quit && inCombat {
                            
                            input = readLine()?.lowercased() ?? "000"
                            if input == "" {
                                input = "000"
                            }
                            
                        }
                    }
                }
            }
            // Animação da tela de gameover
            printBorder()
            printBorder()
            print(gameOver1)
            printBorder()
            sleep(2)
            printBorder()
            print(gameOver2)
            printBorder()
            sleep(2)
            printBorder()
            print(gameOver7)
            printBorder()
            sleep(3)
            printBorder()
            print(gameOver8)
            printBorder()
            sleep(2)
            
            // Animação da última tela de gameover, similar a tela inicial
            enter = "000"
            let kills = player.kills

            if #available(macOS 10.15, *) {
                Task {
                    while enter == "000" {
                        printBorder()
                        printKill1(kills)
                        printBorder()
                        sleep(1)
                        if enter != "000" {
                            break
                        }
                        printBorder()
                        printKill2(kills)
                        printBorder()
                        sleep(1)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
            
            enter = "000"
            enter = readLine() ?? "000"
            
            if enter == "" {
                quit = false
            }
            if enter == "q" {
                quit = true
            }
        }


        // Função para imprimir o HUD do jogo, baseado nas infos do jogador
        func printHud(_ p: Player) {
            // Imprime linha por linha para deixar de fato alinhado e não embaixo
            for i in 0...17 {
                print(heart[i], terminator: "")
                // Verifica se a vida está acima ou igual a 0, para não dar bugs
                if p.life >= 0 {
                    // Calcula qual número imprimir, baseado no index do vetor "numbers"
                    // e utilizando cálculos para saber o número da centena, dezena e unidade
                    print(numbers[p.life/100][i], terminator: "")
                    print(numbers[(p.life/10) % 10][i], terminator: "")
                    print(numbers[p.life % 10][i], terminator: "")
                } else {
                    print(numbers[0][i], terminator: "")
                    print(numbers[0][i], terminator: "")
                    print(numbers[0][i], terminator: "")
                }
                print(empty[i], terminator: "")
                print(empty[i], terminator: "")
                print(skull[i], terminator: "")
                print(numbers[p.kills/100][i], terminator: "")
                print(numbers[(p.kills/10) % 10][i], terminator: "")
                print(numbers[p.kills % 10][i])
            }
        }

        // Função que imprime uma borda preta com 7 linhas de largura
        func printBorder() {
            for i in 1...7 {
                for j in 0...8 {
                    print(empty[j], terminator: "")
                }
                print(empty[0])
            }
        }

        // Função que imprime a tela final com o score de morte
        // funciona similar a printHud(). Essa é a versão que aparece
        // os avisos de pressionar certa tecla
        func printKill1(_ kills: Int) {
            for i in 1...10 {
                print(bigEmpty)
            }
            for i in 0...17 {
                print(empty[i], terminator: "")
                print(empty[i], terminator: "")
                print(empty[i], terminator: "")
                print(skull[i], terminator: "")
                print(numbers[kills/100][i], terminator: "")
                print(numbers[(kills/10) % 10][i], terminator: "")
                print(numbers[kills % 10][i], terminator: "")
                print(empty[i], terminator: "")
                print(empty[i], terminator: "")
                print(empty[i])
            }
            for i in 1...10 {
                print(bigEmpty)
            }
            print(finalScreen)
        }
        // Igual a funçao anterior, contudo, não printa os avisos
        // de pressionar teclas. Usada em conjunto com a outra função
        // para ter animação
        func printKill2(_ kills: Int) {
            for i in 1...10 {
                print(bigEmpty)
            }
            for i in 0...17 {
                print(empty[i], terminator: "")
                print(empty[i], terminator: "")
                print(empty[i], terminator: "")
                print(skull[i], terminator: "")
                print(numbers[kills/100][i], terminator: "")
                print(numbers[(kills/10) % 10][i], terminator: "")
                print(numbers[kills % 10][i], terminator: "")
                print(empty[i], terminator: "")
                print(empty[i], terminator: "")
                print(empty[i])
            }
            for i in 1...29 {
                print(bigEmpty)
            }
        }
    }
}
