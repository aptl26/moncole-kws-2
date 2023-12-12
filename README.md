# KWS model for Brilliant Labs Monocle

This project focuses on implementing a Keyword Spotting (KWS) model designed for the Brilliant Labs Monocle augmented reality device. The solution utilizes a TensorFlow Lite Micro model, enabling efficient deployment on low-powered microcontrollers embedded in the Monocle AR device.

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Acknowledgements](#acknowledgements)

## Project Overview

The primary objective of this project is to develop a lightweight yet accurate KWS model capable of running seamlessly on the Monocle AR device. Keyword Spotting allows the device to recognize specific spoken keywords or commands, enhancing user interaction and control.

## Features

- TensorFlow Lite Micro Integration: Utilizes TensorFlow Lite Micro to optimize the KWS model for execution on resource-constrained microcontrollers.
- Low-Powered MCU Support: Tailored for efficient operation on the Monocle AR device, maximizing performance on limited hardware resources.
- Keyword Recognition: Enables the Monocle AR device to identify and respond to predefined keywords, enhancing user engagement and functionality.

## Getting Started

Explain how to set up and run your project on a local machine.

### Prerequisites

List any software, libraries, or dependencies that need to be installed before running your project.  

Ensure that you have the [nRF Command Line Tools](https://www.nordicsemi.com/Products/Development-tools/nrf-command-line-tools) installed  

Download Brilliant Labs AR Studio to your editor (we used VS Code)  

### Installation

Provide step-by-step instructions on how to install and configure your project.  

Before running commands for the nRF52DK board, you'll probably have to unlock the board with the following command:  
```bash
  nrfjprog --recover 
```  
To get the firmware and model flashed to the model:  
```bash
  make flash
```
To open the REPL, do the following:  
CMD + SHIFT + P and click Brilliant AR Studio: Connect  

Finally, to run the model, run the following commands in the REPL:  
```bash
  import kws  
  kws.run()
```  

## Usage

Provide examples and instructions on how to use your project.

```bash
Example:
node app.js
```



## Acknowledgements

Special thanks to Harrison Zhang, who's repository here was the basis for our project. Furthmore, we would like to thank Professor Vijay Reddi and the rest of Harvard's COMPSCI 249r: TinyML course staff for their instruction and support.
