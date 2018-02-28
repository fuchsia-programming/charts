import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt


auto = pd.read_csv('assets/data/auto.csv')
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
