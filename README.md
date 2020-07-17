# sounds-and-lua-notakid-required
A "base" type addon I guess with useful functions for my addons, as well as sounds.

In OnSpawn:
# NAK.SpawnColor(ent, select)
ent is the vehicle, select is optional.
If you have select set to 1 it will use SetColor(), 0 is SetProxyColor().
If select is nil, and ProxyColor is not installed, it will default to SetColor().
(may seem a little complicated but i need the options)

# NAK.TireOverride( ent, stringBodygroupsBroken, stringBodygroupsRepaired, GhostWheelPos, ElasticHeight )
Creates NetworkNotify things to patch simfphys tire popping. (no overriding, just runs after)
ent is the vehicle
stringBodygroups -> https://wiki.facepunch.com/gmod/Entity:SetBodyGroups
GhostWheelPos is the up/down position of the ghost wheel. Can be used to make the rim not go through ground.
ElasticHeight sets the suspension height for that wheel when broken, can be used to make the wheel closer to middle when broken.

# NAK.NetworkAnim(ent)
ent is vehicle
This enables airboat animation on vehicle, possibly useful for bike simfphys!


The sounds have to be cleaned up and sorted still. Have not gotten around to it.
There are a few broken duplicates and random folders.

Included models are shared weapon models mostly, like missles and mortars. Still wip.
