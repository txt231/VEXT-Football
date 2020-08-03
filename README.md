# VEXT-Football

some simple football mod, now with ghetto syncing included!

Code is kinda shitty tho, and i dont think the style is consistent, but oh well...

# How it works

creates a custom entitiy, with a invisible collision ball as the havok data and Red_Glow for shader (probably exists some better shaders)

Spawn is triggered by a client. The client becomes the host of the ball, and updates the ball for the rest of the players

# Keybinds

B - spawns a synced ball<br>
N - spawns a local ball

# Figure out maybe

- possibly spawn a staticmodelentity version of the ball on the server so theres some form of collision. Right now you can just walk through the ball like its nothing
- custom MeshVariationDB (might be able to add one to the partition)

# Issues
- no proper unloading, can crash your game if you do stuff (freezes your game on disconnect on newer vu versions, prod works fine for now)
- syncing is heavily ping dependent
- bad collisions can puncture the ball and dissapears. might cause a crash if someone else punctures your ball :(
- sends alot of updates, not good for performance and lots of players.
- collisioncallback doesnt react on bullets, which i want... might have to do some event callback or something as well


# Some stolen codenz

- stole some bundle mounting stuff from @Powback, you see it in `Shared/__init__`
