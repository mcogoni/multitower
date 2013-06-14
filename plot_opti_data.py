#!/usr/bin/env python
import time
from pylab import *
import numpy as np
import matplotlib.pyplot as plt


with open("geo_torri") as geo_torri_fd:
	tower_positions = geo_torri_fd.readlines()

with open("solar_land") as solar_land_fd:
	heliostat_positions = solar_land_fd.readlines()

with open("tower-map.history") as tower_map_history_fd:
	heliostat_mapping = tower_map_history_fd.readlines()

with open("out") as energy_fd:
	energy = energy_fd.readlines()

energy_vect = []
energy_steps = []
for i, line in enumerate(energy):
	if len(line.split()) > 1:
		energy_vect.append(float(line.split()[1]))
		energy_steps.append(i)

print len(energy_steps), len(energy_vect)

max_en =  max(energy_vect)
min_en =  min(energy_vect)

n_helios = int(heliostat_positions.pop(0))
print n_helios

n_towers = int(tower_positions.pop(0))
print n_towers

color_code = {0: 'black', 1: 'red', 2: 'blue', 3: 'cyan', 4:'yellow'}

tmp_split = []

x_tower = []
y_tower = []
h_tower = []
tower_color = []

for i, el in enumerate(tower_positions):
	tmp_split = el.split()
	x_tower.append(float(tmp_split[0]))
	y_tower.append(float(tmp_split[1]))
	h_tower.append(float(tmp_split[2]))
	tower_color.append(color_code[i+1])
	
x_helios = []
y_helios = []
h_helios = []
type_helios = []
size_helios = []

for el in heliostat_positions:
	tmp_split = el.split()
	x_helios.append(float(tmp_split[0]))
	y_helios.append(float(tmp_split[1]))
	h_helios.append(float(tmp_split[2]))
	type_helios.append(float(tmp_split[3]))
	size_helios.append(float(tmp_split[4]))

mapping_step = []	
steps = len(heliostat_mapping)/n_helios
mapping_color = []
for index in range(steps):
	mapping_step.append(heliostat_mapping[index*n_helios:(index+1)*n_helios])
	mapping_step[index] = map(int, mapping_step[index])
	mapping_color.append([color_code[el] for el in mapping_step[index]])
	


min_x_helios = min(x_helios)
max_x_helios = max(x_helios)
min_y_helios = min(y_helios)
max_y_helios = max(y_helios)

ion()

#fig = plt.figure(figsize=(8, 6))
#ax = fig.add_subplot(111, axisbg='#FFFFCC')


fig = plt.figure(figsize=(16, 8))

for step in range(0, len(mapping_step), 10):

	# Configurations
	plt.subplot(121)
	scatter(x_helios, y_helios, c = mapping_color[step], s = 50)		
	scatter(x_tower, y_tower, c = tower_color, s = 300)

#	x_helios_left = map(lambda x: x*-1 - 2*max_x_helios, x_helios)
#	y_helios_left = y_helios 
#	scatter(x_helios_left, y_helios_left, c = mapping_color[step], s = 50)		
	
	xlim(min_x_helios-50, max_x_helios+50)
	ylim(min_y_helios-50, max_y_helios+50)
	plt.xlabel("X coord (m)")
	plt.ylabel("Y coord (m)")
	plt.title("Configurations")
	plt.grid(True)
	
	# Energy
	plt.subplot(122)
	plt.plot(range(step), energy_vect[0:step])
	xlim(0, 2100)
	ylim(min_en / 1.1 , max_en * 1.1)
	plt.xlabel("Steps")
	plt.ylabel("Energy (MW)")
	plt.title("Energy Optimization")
	plt.grid(True)
	
	#plt.show()
	draw()
	#time.sleep(0.1)
	filename = 'img.' + str(step/10).zfill(5) + '.png'
	plt.savefig(filename)
	clf()
	print step
