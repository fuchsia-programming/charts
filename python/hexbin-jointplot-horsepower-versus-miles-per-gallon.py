import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt


auto = pd.read_csv('assets/data/auto.csv')

sns.jointplot(x='hp', y='mpg', data=auto, kind='hex')
plt.xlabel('Horsepower (hp)')
plt.ylabel('Miles per gallon (mpg')

fig = plt.gcf()
fig.set_size_inches(8, 8)
fig.savefig('python/images/hexbin-jointplot-hp-versus-mpg.png', dpi=80)
