# ***************************** Text-based fight game with semi-random outcomes *****************************

# Demonstration for:
# - Objects
# - Stopwatches
# - Nested loop
# - Random outcomes
# - Partially random outcomes
# - Arraylists

Clear-Host

# Simplest way to create an object is to simply assign it to a variable ...
$elf = New-Object PSObject

# ... Then add some properties using Add-Member.
Add-Member -InputObject $elf -MemberType NoteProperty -Name Weapon -Value "Bow and Arrows"
Add-Member -InputObject $elf -MemberType NoteProperty -Name AttackStrength -Value 8

# If you've got lots of properties you want to assign to it, then we reverse the order a bit
# and create the properties first using a hash table ...
$trollprops = @{
Name = "Troll"
Weapon = "Axe"
Powers = "Super strength"
Weaknesses = "Tires quickly"
AttackStrength = 6
}

# ... Then assign those properties to our object
$troll = New-Object PSObject -Property $trollprops

# Now let's add some dialogue for the user
Write-Host "Welcome to Fantasy Fights!"

# We're going to use a stopwatch to make things more dramatic
$stopwatch = New-Object System.Diagnostics.Stopwatch

# Going to go ahead and make a second one for later
$minisw = New-Object System.Diagnostics.Stopwatch

# Give people time to read title
$stopwatch.Start()
While($stopwatch.Elapsed.Seconds -lt 1){$null}
$stopwatch.Stop()

# To condense our code, I'm going to do a nested loop to play the dialogue with two different stopwatch settings
# This way we don't have to write out stop/reset/start for the stopwatch as many times. This makes the code easy
# to scale as we could now add as many fighters and their dialogue as we want without increasing the code length.
#****************************************************************************************************************
# First, add all dialogue to an array
# - To call up any property of an object, just use dot notation
$dialogue = @("Fighter one steps into the ring! He is ...",
"... a TROLL!",
"Trolls carry an $($troll.Weapon) and have default attack strength of $($troll.AttackStrength)",
"Fighter two steps into the ring! He is ...",
"... an ELF!",
"Elves carry a $($elf.Weapon) and have default attack strength of $($elf.AttackStrength)"
)

# Create counters to determine outside & inside loop iterations and the total number of iterations combined
$outsidecounter = 0
$insidecounter = 0
$counter = 0

# Nested loops. We need two iterations of the outer loop and two of inner loop to iterate through all 6 dialogue pieces
# Using two different stopwatch settings allows us to pause longer after each fighter is announced.
Do{
    Do{   
        # Use $counter to determine which dialogue to use on a given iteration
        Write-Host $dialogue[$counter]

        # Wait 1 second
        $stopwatch.Reset()
        $stopwatch.Start()
        While($stopwatch.Elapsed.Seconds -lt 1){$null}
        $stopwatch.Stop()

        # Increment
        $insidecounter++
        $counter++

    } While($insidecounter -lt 2)

    Write-Host $dialogue[$counter]

    # Wait 2 seconds
    $stopwatch.Reset()
    $stopwatch.Start()
    While($stopwatch.Elapsed.Seconds -lt 2){$null}
    $stopwatch.Stop()

    # Reset/increment
    $insidecounter = 0
    $counter++
    $outsidecounter++

} While($outsidecounter -lt 2)

# Now everyone is announced, it's time to fight!
#**********************************************************************************************

# Give user their first choice
$attack? = Read-Host "Let's make them fight? (y,n)"

If($attack? -eq "y"){
    Write-Host "Let's see who'll win ..."

    $stopwatch.Reset()
    $stopwatch.Start()
    While($stopwatch.Elapsed.Milliseconds -lt 300){$null}
    $stopwatch.Stop()

    Write-Host "... you can choose their strength, but remember, even a very strong fighter can lose if he has bad luck"
    Write-Host "For a complete toss-up of a match, give each fighter equal strength"

    # To change the value of any existing object property, just use = 
    $elf.AttackStrength = Read-Host "Enter a number for the elf's attack strength (1-10)"
    $troll.AttackStrength = Read-Host "Enter a number for the troll's attack strength (1-10)"

    Write-Host "Fight is commencing ..."

    $stopwatch.Reset()
    $stopwatch.Start()
    While($stopwatch.Elapsed.Seconds -lt 1){$null}
    $stopwatch.Stop()

    # Let's do some fight graphics
    $arr_graphics = "AIEEE!", "CRUNCH","BANG!","EEE-YOW!","FLRBBBBB!","KAPOW!","OOOOFF!","OUCH!","SWOOSH!","THWACK!","WHACK!","ZWAPP!"

    # Here we have a 4 second 'fight' to display to the user (actual fight doesn't take place until later, this is just for show)
    # Our mini stopwatch slows down the iterations so normal humans can follow along
    # Random number cmdlet picks a fight graphic from the array to display for every iteration
    $stopwatch.Reset()
    $stopwatch.Start()
    While($stopwatch.Elapsed.Seconds -lt 4){

        $minisw.Reset()
        $minisw.Start()
        While($minisw.Elapsed.Milliseconds -lt 300){$null}
        $minisw.Stop()
        
        $random = Get-Random -Minimum 0 -Maximum 11
        Write-Host $arr_graphics[$random]
    }
    $stopwatch.Stop()

    # Now, calculate outcome:
    # Although you can assign an attack advantage to one object or another, that does not guarantee their success.
    #************************************** Partial or fully Random Outcome **************************************

    # Determine winner by assigning % advantage & iterate to see who wins the most. 
    # - Will iterate 100 times
    # - Each iteration, a random # between 1-10 will be chosen for each fighter. Highest wins.
    # - Each 10% advantage gives 10 chances to beat the opponant where opponant can't win.
    
    $trolladv = [int]$troll.AttackStrength * 10 # Calculate % out of 100 for each
    $elfadv = [int]$elf.AttackStrength * 10 # We must cast the properties as int do math
    $counter = 0
    [System.Collections.ArrayList]$elfscore = @() # Arraylists to hold scores
    [System.Collections.ArrayList]$trollscore = @()

    # Boolean to keep track of if we're on a free attack or not
    $bln_free = $true

    # Calculate free attacks
    If($trolladv -gt $elfadv){
        $freeattacks = $trolladv - $elfadv
    } ElseIf($elfadv -gt $trolladv){
        $freeattacks = $elfadv - $trolladv
    } Else {
        $freeattacks = 0
        $bln_free = $false
    }

    Do{
        # First, calculate a new attack strength for each before each fight iteration
        $troll.AttackStrength = Get-Random -Minimum 1 -Maximum 10
        $elf.AttackStrength = Get-Random -Minimum 1 -Maximum 10

        # Run free attacks first
        If($bln_free -eq $true){

            # Depending on who had the initial advantage
            If($trolladv -gt $elfadv){

                If($troll.AttackStrength -gt $elf.AttackStrength){
                    # Add to arraylist. To prevent console feedback, void return value
                    [void]$trollscore.Add(1)
                }
            } Else {

                If($elf.AttackStrength -gt $troll.AttackStrength){
                    [void]$elfscore.Add(1)
                }
            }

        # Run fair attacks
        } Else {
            If($troll.AttackStrength -gt $elf.AttackStrength){
                [void]$trollscore.Add(1)
            } Elseif($troll.AttackStrength -lt $elf.AttackStrength){
                [void]$elfscore.Add(1)
            } Elseif($troll.AttackStrength -eq $elf.AttackStrength){
                # If both are equal strength, we get random numbers for each until one wins
                Do{
                    $elf.AttackStrength  = Get-Random -Minimum 1 -Maximum 10
                    $troll.AttackStrength = Get-Random -Minimum 1 -Maximum 10
                } While($troll.AttackStrength -eq $elf.AttackStrength )

                If($troll.AttackStrength -gt $elf.AttackStrength ){
                    [void]$trollscore.Add(1)
                } ElseIf($troll.AttackStrength -lt $elf.AttackStrength ){
                    [void]$elfscore.Add(1)
                }
            }
        }
            
        # Increment $counter & cut off $bln_free at appropriate iteration
        $counter++
        If($counter -ge $freeattacks){
            $bln_free = $false
        }
    } While($counter -lt 100)

    # Calculate total score for each
    $counter = 0
    $elftotal = 0
    $trolltotal = 0
    Do{
        $elftotal++
        $counter++
    } Until($counter -eq $elfscore.Count)

    $counter = 0
    Do{
        $trolltotal++
        $counter++
    } Until($counter -eq $trollscore.Count)

    # Display results

    # Separator so people can see the outcome better
    Write-Host "***************************"

    If($trolltotal -gt $elftotal){
        Write-Host "Troll wins!"
    } ElseIf($elftotal -gt $trolltotal){
        Write-Host "Elf wins!"
    } Else {
        Write-Host "It's a tie!"
    }

    $ties = 100 - ($elftotal + $trolltotal)

    Write-Host ""
    Write-Host "Statistics:"
    Write-Host "Elf won ${elftotal} bouts"
    Write-Host "Troll won ${trolltotal} bouts"
    Write-Host "${ties} bouts were ties"
    Write-Host "***************************"

    # Clear arraylists in preperation for next time
    $elfscore.Clear()
    $trollscore.Clear()

} Else {
    Write-Host "Laaame, but ok they can just hug and make up instead then."
}
