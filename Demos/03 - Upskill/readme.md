# Upskill with dbatools

- Problem solving
    - catching errors/exceptions

- Error Handling
    - including catch for individual exceptions
- Logging
- Default Parameters
- Splatting

# When we compare a list or a collection

# -eq it turns into filter mode

$amIhere = 1,2,3,4,5,5,5,6
$amIhere -eq 5

# when we compare a scalar

# it works like we think

$amIHere = Get-Random -min 0 -max 10
$amIhere -eq 5

https://blog.iisreset.me/schrodingers-argumentlist/