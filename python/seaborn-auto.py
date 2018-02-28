import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt


auto = pd.read_csv('assets/data/auto.csv')
sns.lmplot(x='weight', y='hp', data=auto, hue='origin')
plt.title('Automobile weight versus horsepower by Continent')
plt.ylabel('Horsepower (hp)')
plt.xlabel('Weight')
fig = plt.gcf()
fig.set_size_inches(8, 8)
fig.savefig('python/images/automobile-weight-versus-horsepower-by-continent.png', dpi=80)
