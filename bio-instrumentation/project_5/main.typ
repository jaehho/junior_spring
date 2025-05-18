#import "conf.typ": ieee

#show: ieee.with(
  title: [Not-Quite Pulse Oximeter],
  abstract: [
    This project presents a basic implementation of a pulse oximeter using a red LED and a phototransistor. The design focuses on detecting the user’s pulse rate by measuring variations in transmitted red light through the tip of a finger. A high-pass filter is employed to isolate the low frequency target signal, which is then amplified using an instrumentation amplifier. The resulting waveform is analyzed on an oscilloscope to estimate the heart rate, demonstrating the viability of a simplified oximeter circuit for pulse detection.
  ],
  index-terms: ("Pulse Oximeter", "Phototransistor"),
  authors: (
    (
      name: "Jaeho Cho",
      department: [ECE444 - Bioinstrumentation and Sensing],
      organization: [The Cooper Union for the Advancement of Science and Art],
      location: [New York City, NY],
      email: "jaeho.cho@cooper.edu",
    ),
  ),
  bibliography: bibliography("refs.bib"),
)

= Introduction

Pulse oximeters are non-invasive devices used to monitor heart rate and blood oxygen saturation by analyzing the absorption of light through body tissues. While commercial systems typically utilize both red and infrared light to distinguish between oxygenated and deoxygenated hemoglobin, this project simplifies the approach by using only a red LED and a phototransistor. The goal is to demonstrate the feasibility of detecting a pulse signal through variations in light intensity, filtered and amplified to produce a measurable electrical output. This implementation offers a low-cost and accessible platform for understanding the fundamental principles behind pulse oximetry.

= Methodology

// placed here for better visualization
#figure(
  image("assets/schematic.png"),
  caption: "Schematic of pulse oximeter circuit.",
  placement: auto,
)<fig:schematic>

The pulse oximeter circuit was implemented using a phototransistor and a red LED. A red LED was chosen as green light does not penetrate through the finger as well as red and near infrared light @UpdatingPulseOximeters2023. The current of the phototransistor was converted to a voltage using a resistor, which was then sent through a high-pass filter to remove noise and focus on the low ~1 Hz pulse rate. The high-pass filter is designed with a measured 0.47 #sym.mu F capacitor and a 9.85 k #sym.Omega resistor, which gives a cutoff frequency of approximately 34.38 Hz. The output of the high-pass filter was then sent to the previously built instrumentation amplifier circuit @choInstrumentationAmplifier25. The second input of the instrumentation amplifier was connected to a variable virtual ground to control the DC offset of the output signal, this is because the change in voltage from the phototransistor due to the pulse is very small relative to any physical movements or environmental lighting. @fig:schematic shows the schematic of the pulse oximeter circuit, and @fig:circuit shows a picture of the implemented circuit.

#figure(
  image("assets/circuit.jpg"),
  caption: "Picture of implemented circuit.",
  placement: auto,
  scope: "parent"
)<fig:circuit>

= Results & Discussion

@fig:scope shows the output of the pulse oximeter circuit on an oscilloscope. Using the oscilloscope's cursors, the pulse rate was measured to be approximately 1 Hz which translates to a heart rate of 60 beats per minute. This is consistent with the expected heart rate of a resting adult.

#figure(
  image("assets/scope_pulse.png"),
  caption: "Oscilloscope Screenshot of Pulse Oximeter Signal showing the ~1 Hz pulse rate.",
  placement: none,
)<fig:scope>