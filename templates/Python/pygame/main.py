#!/usr/bin/env python3
import pygame; # library to generate the graphic interface
import time; # to set a delay between each iteration
from Classes.color import color;

pygame.init() # Init pygame
pygame.display.set_caption("") # Set the title of the game

# CONSTANTS
width, height = 1000, 1000 
sizeX, sizeY = 50, 50 # Number of cell spots in each axis
sizeWidthX = width / sizeX # Size of each spot
sizeWidthY = height / sizeY
COLOR = color() # Get the color class with the constants

screen = pygame.display.set_mode((width, height)) # Set the size of the window

gameRunning = True # If false, the game stops
timeRunning = False # If true, time runs (so iterations occur)
while gameRunning:
	screen.fill(COLOR.BG) # Clean screen

	if timeRunning:
		time.sleep(0.1) # set a delay between each iteration
	pygame.display.flip() # Update the screen

	for event in pygame.event.get(): # for each event
		if event.type == pygame.QUIT: # if quit btn pressed
			gameRunning = False # no longer running game
		elif event.type == pygame.KEYDOWN: # Key pressed
			if event.key == 32: # Space pressed
				timeRunning = not timeRunning # Toggle the run of iterations

print("Thanks for playing, I hope you liked it.")
print("See more projects like this one on https://github.com/jkutkut/")
pygame.quit() # End the pygame
