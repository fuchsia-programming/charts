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
