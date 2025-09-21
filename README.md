# Sensor-Calibration-and-Dynamic-Compensation

The aim of this project is to reconstruct the acceleration of a vibrating structure from the raw voltage signal measured by a displacement sensor (magnet-based).
Since the sensor does not measure acceleration directly, a static calibration and a dynamic compensation are required to relate the sensor voltage to the physical displacement, and then recover acceleration through the system dynamics.
Effectively, the whole device behaves like a homemade accelerometer:
•	The mechanical part acts as a mass–spring–damper system,
•	The electrical part (Hall sensor) converts the magnet motion into a measurable voltage,
•	By combining static calibration and dynamic compensation, the raw voltage can be transformed into the actual acceleration of the box.


1. Static Calibration (t_statica.m)

The static calibration establishes the relation between the sensor voltage and the displacement of the magnet.

Data are collected from a controlled static test.

A polynomial fit is applied to convert voltage values into displacement values.

The resulting calibration function is later used to process dynamic measurements.

2. Dynamic Test and System Identification (dinamica_fit.m)

A free oscillation test is performed to identify the dynamic parameters of the system.

The box is shaken and released, producing a damped oscillatory response.

The recorded signal is fitted with a damped sinusoidal model.

From this fitting process, the natural frequency and damping ratio are estimated.
These parameters are then used to model the mechanical system as a mass–spring–damper oscillator.

3. Signal Processing (main_dinamica.m)

The dynamic test data are imported from oscilloscope recordings (e.g. scope(6).csv).

The raw voltage signal is first converted into displacement using the static calibration function.

A low-pass Butterworth filter is applied to remove high-frequency noise.

The filtered displacement signal is transformed into the frequency domain using the Fourier transform.

4. Dynamic Compensation (main_dinamica.m)

To reconstruct acceleration, the dynamics of the mass–spring–damper system are inverted.

A transfer function is defined based on the identified system parameters.

The displacement spectrum is multiplied by the inverse of this transfer function.

The corrected signal is then brought back to the time domain using the inverse Fourier transform.

As a result, the acceleration of the box can be obtained from the original voltage measurement of the Hall sensor.

5. Results

Displacement signal: obtained from static calibration and filtering.

Acceleration signal: reconstructed after dynamic compensation.

Bode plots: validate the identified system model and show its frequency response.


👉 This project demonstrates how a simple magnet–spring–Hall sensor assembly, enclosed in a 3D-printed box, can be transformed into a working accelerometer using a combination of experimental calibration and signal processing techniques.
