import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt

auto = pd.read_csv('assets/data/auto.csv')

plt.subplot(2,1,1)
sns.violinplot(x='cyl', y='hp', data=auto)
plt.xlabel('Cylinders')
plt.ylabel('Horsepower (hp)')

plt.subplot(2,1,2)
sns.violinplot(x='cyl', y='hp', data=auto, inner=None, color='lightgray')
sns.stripplot(x='cyl', y='hp', data=auto, jitter=True, size=1.5)

plt.xlabel('Cylinders')
plt.ylabel('Horsepower (hp)')
plt.title('Violin plot of automobile cylinders versus horsepower', y=2.3)
fig = plt.gcf()
fig.set_size_inches(8, 8)
fig.savefig('python/images/violin-plot-cylinders-versus-hp.png', dpi=80)

fig.clf()



# Generate a swarm plot of 'hp' grouped horizontally by 'cyl'
plt.subplot(2,1,1)
sns.swarmplot(x='cyl', y='hp', data=auto)
plt.xlabel('Cylinders')
plt.ylabel('Horsepower (hp)')

# Generate a swarm plot of 'hp' grouped vertically by 'cyl' with a hue of 'origin'
plt.subplot(2,1,2)
sns.swarmplot(x='hp', y='cyl', data=auto, hue='origin', orient='h')
plt.xlabel('Horsepower (hp)')
plt.ylabel('Cylinders')

plt.title('Swarmplot of automobile cylinders versus horsepower', y=2.3)
fig = plt.gcf()
fig.set_size_inches(8, 8)
fig.savefig('python/images/automobile-swarmplot-hp-versus-cylinders.png', dpi=80)

fig.clf()




sns.lmplot(x='weight', y='hp', data=auto, hue='origin')
plt.title('Automobile weight versus horsepower by Continent')
plt.ylabel('Horsepower (hp)')
plt.xlabel('Weight')
fig = plt.gcf()
fig.set_size_inches(8, 8)
fig.savefig('python/images/automobile-weight-versus-horsepower-by-continent.png', dpi=80)

fig.clf()



sns.jointplot(x='hp', y='mpg', data=auto, kind='hex')
plt.xlabel('Horsepower (hp)')
plt.ylabel('Miles per gallon (mpg')

fig = plt.gcf()
fig.set_size_inches(8, 8)
fig.savefig('python/images/hexbin-jointplot-hp-versus-mpg.png', dpi=80)


fig.clf()