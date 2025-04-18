import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def process_raw_data(filepath="sensor_raw.csv"):
    df = pd.read_csv(filepath)
    df['time'] = df['timestamp'] - df['timestamp'].iloc[0]

    # downsample
    df_sampled = df.iloc[::10].copy()
    fig, axes = plt.subplots(3, 2, figsize=(15, 12))
    fig.suptitle("Raw Sensor Data Analysis", fontsize=16)

    sensors = {
        'acc': {'cols': ['acc_x', 'acc_y', 'acc_z'], 'title': 'Accelerometer'},
        'gyro': {'cols': ['gyro_x', 'gyro_y', 'gyro_z'], 'title': 'Gyroscope'}
    }

    for i, (sensor_type, info) in enumerate(sensors.items()):
        for j, axis in enumerate(['x', 'y', 'z']):
            col = info['cols'][j]
            ax = axes[j, i]

            ax.plot(df_sampled['time'], df_sampled[col],
                    label=f'{axis.upper()}-axis', alpha=0.7)

            mean = df[col].mean()
            std = df[col].std()

            ax.set_title(f"{info['title']} {axis.upper()}-axis\n"
                         f"Bias: {mean:.6f}, Noise: {std:.6f}")
            ax.set_xlabel("Time (s)")
            ax.grid(True)

    plt.tight_layout()
    plt.savefig('sensor_raw_analysis.png')
    plt.show()
    plt.close()


def compare_readings(files=[
    "reading_acc.csv",
    "reading_gyr.csv",
    "reading_fusion.csv"
]):
    plt.figure(figsize=(12, 6))

    for file in files:
        df = pd.read_csv(file)

        df['time'] = df['timestamp'] - df['timestamp'].iloc[0]

        # downsample
        df_sampled = df.iloc[::10]

        label = file.split('_')[1].split('.')[0]
        if label=='fusion':label = 'complementary'
        plt.plot(df_sampled['time'], df_sampled['angle'],
                 label=label.capitalize(), alpha=0.8)

    # 图表装饰
    plt.title("Tilt Angle Comparison")
    plt.xlabel("Time (s)")
    plt.ylabel("Angle (degrees)")
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.savefig('tilt_comparison.png')
    plt.show()
    plt.close()

if __name__ == "__main__":
    process_raw_data()
    compare_readings()