# Assignment-1-of-AAE6102_23062929r

## Task 1: Acquisition
Process the IF data using a GNSS SDR and generate the initial acquisition results.

The purpose of acquisition is to identify visible satellites and estimate the approximate values of the **carrier phase** and **code phase** of the satellite signals. 

**carrier phase**: Used for downconversion, including the Doppler effect.

**code phase**: Generates a local PRN code to align with the incoming signal.  
 
The acquisition algorithm used here is  **Parallel Code Phase search acquisition** . 

**Step 1**: Generate the carrier frequency with various Doppler shifts. The frequency step is 500 Hz, and the range is from -7 kHz to 7 kHz.
```
  frqBins(frqBinIndex) = settings.IF - settings.acqSearchBand + ...
                                             0.5e3 * (frqBinIndex - 1);
```
**Step 2**：Perform Parallel Code Phase search acquisition for a single satellite using 20 ms of data.
```
  caCodeFreqDom = conj(fft(caCodesTable(PRN, :)));
......
  IQfreqDom1 = fft(I1 + 1i*Q1);
  IQfreqDom2 = fft(I2 + 1i*Q2);
......
 convCodeIQ1 = IQfreqDom1 .* caCodeFreqDom;
 convCodeIQ2 = IQfreqDom2 .* caCodeFreqDom;
......
   acqRes1 = abs(ifft(convCodeIQ1));
   acqRes2 = abs(ifft(convCodeIQ2));
```
**Step 3**：Set the acquisition threshold and proceed to fine acquisition.
### Acquisiton result (Opensky.bin)

Five GPS satellites (PRN 16, 22, 26, 27, and 31) have been successfully acquired, with their code delay and Doppler information displayed below

| Satellite PRN | Doppler Frequency (Hz) | Code Phase |
|---------------|------------------------|------------|
| 16            | -240.4022216796875     | 31994      |
| 26            | 1916.8090820303187     | 57754      |
| 31            | 1066.3700103797019     | 18744      |
| 22            | 1571.102142330259      | 55101      |
| 27            | -3220.396041870117     | 8814       |

![image](result/task1/opensky/Screenshot 2025-03-13 105559.jpg)

GPS satellites PRN 16, 22, 26, 27, and 31 have been successfully acquired! The corresponding skyplot is displayed below.

![image](https://github.com/user-attachments/assets/5ebe4e29-f3e7-4747-a05d-3d260cfa8b4f)

### Acquistion result (Urban.dat)

Four GPS satellites (PRN 1, 3, 11, and 18) have been successfully acquired, with their code delay and Doppler information displayed below

| Satellite PRN | Doppler Frequency (Hz) | Code Phase |
|---------------|------------------------|------------|
| 1             | -4578797.416687012     | 3329       |
| 3             | -4575710.372924805     | 25173      |
| 11            | -4579590.873718262     | 1155       |
| 18            | -4580322.341918945     | 10581      |

![image](https://github.com/user-attachments/assets/84d3597b-a623-4d48-a4a9-ba3a3e2e0afc)

GPS satellites PRN 1, 3, 11, and 18 have been successfully acquired! The corresponding skyplot is displayed below.

![image](https://github.com/user-attachments/assets/a37639ed-5b1e-4c0e-b7a8-27bc2cf877f1)

Compared to open-sky environments, fewer GPS satellites are acquired due to the obstruction caused by buildings.In open-sky environments, GPS receivers have a clear line of sight to a larger number of satellites, which allows for more accurate and reliable positioning. However, in urban areas or environments with significant obstructions, such as tall buildings, the number of visible satellites is reduced. This phenomenon is known as urban canyon effect.

Buildings and other structures can block or reflect GPS signals, leading to a decrease in the number of satellites that the receiver can acquire. This can result in several issues:

    Reduced Accuracy: With fewer satellites, the GPS receiver has less information to calculate an accurate position. This can lead to errors in the reported location.

    Signal Multipath: Reflected signals from buildings can cause multipath errors, where the GPS receiver picks up both the direct and reflected signals, further degrading accuracy.

    Intermittent Signal Loss: In dense urban environments, the GPS receiver may frequently lose and reacquire signals, leading to intermittent positioning data.

Overall, the presence of buildings and other obstructions significantly impacts the performance of GPS receivers, making it challenging to maintain a stable and accurate position fix. This is why fewer satellites are acquired in such environments compared to open-sky conditions.

## Task 2: Tracking
### 2.1 Code Analysis
The purpose of tracking is to refine the carrier frequency and code phase values, ensuring continuous monitoring.

For code tracking, an early-late prompt discriminator with a spacing of 0.5 chips is used.

Calculate the correlator output
```
            I_E = sum(earlyCode  .* iBasebandSignal);
            Q_E = sum(earlyCode  .* qBasebandSignal);
            I_P = sum(promptCode .* iBasebandSignal);
            Q_P = sum(promptCode .* qBasebandSignal);
            I_L = sum(lateCode   .* iBasebandSignal);
            Q_L = sum(lateCode   .* qBasebandSignal);

```
Employing a Delay Lock Loop (DLL) discriminator to fine-tune the code phase.
```
 codeError = (sqrt(I_E * I_E + Q_E * Q_E) - sqrt(I_L * I_L + Q_L * Q_L)) / ...
                (sqrt(I_E * I_E + Q_E * Q_E) + sqrt(I_L * I_L + Q_L * Q_L));
```
### 2.2 Multi-correlator Gerneration

**To derive the Autocorrelation function, it is necessary to implement multiple correlators.**

In this case, **multiple correlators with a spacing of 0.1 chips, ranging from -0.5 chips to 0.5 chips, are utilized.**
```
            tcode       = (remCodePhase-0.4) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase-0.4);
            tcode2      = ceil(tcode) + 1;
            earlyCode04    = caCode(tcode2);
            tcode       = (remCodePhase-0.3) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase-0.3);
            tcode2      = ceil(tcode) + 1;
            earlyCode03    = caCode(tcode2);
            tcode       = (remCodePhase-0.2) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase-0.2);
            tcode2      = ceil(tcode) + 1;
            earlyCode02    = caCode(tcode2);
            tcode       = (remCodePhase-0.1) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase-0.1);
            tcode2      = ceil(tcode) + 1;
            earlyCode01    = caCode(tcode2);
            tcode       = (remCodePhase+0.1) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase+0.1);
            tcode2      = ceil(tcode) + 1;
            lateCode01    = caCode(tcode2);
            tcode       = (remCodePhase+0.2) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase+0.2);
            tcode2      = ceil(tcode) + 1;
            lateCode02   = caCode(tcode2);
            tcode       = (remCodePhase+0.3) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase+0.3);
            tcode2      = ceil(tcode) + 1;
            lateCode03    = caCode(tcode2);
            tcode       = (remCodePhase+0.4) : codePhaseStep : ((blksize-1)*codePhaseStep+remCodePhase+0.4);
            tcode2      = ceil(tcode) + 1;
            lateCode04   = caCode(tcode2);

```
### Comparisoin between the tracking result from Urban and Open sky data
This section contrasts the tracking results from urban data (acquisition results from GPS satellite PRN 18) with those from open-sky data (acquisition results from GPS satellite PRN 16). The acquisition results from GPS satellite PRN 16 from open-sky data and GPS satellite PRN 18 from urban data are used as examples.

### 2.3 Tracking result from open sky data (acquisition results from GPS satellite PRN 16)
![image](https://github.com/user-attachments/assets/9f877a1b-f4e7-4335-84ec-78406e80fb90)

**Q-Channel Near Zero:** Ideally, the Q-channel contains only noise and residual error, with values fluctuating around zero. This indicates that the carrier phase is aligned.

![image](https://github.com/user-attachments/assets/3861d8ca-689e-40c2-bd93-3bc4a3a47df4)

**DLL Output (Code Discriminator Output) Near Zero:** This shows that the local code is aligned with the received signal's code phase, indicating minimal code tracking error.

![image](https://github.com/user-attachments/assets/5a1c4749-6351-4903-aa04-a4b4d573adaa)

**PLL Output (Phase/Frequency Discriminator Output) Near Zero:** This indicates that the local carrier is synchronized with the received signal carrier, ensuring stable carrier tracking.

![image](https://github.com/user-attachments/assets/e7c34ef3-821f-441e-8537-66dd71ca2b07)

**Prompt Correlation Greater than Early/Late:** This signifies that the code phases are precisely aligned, and the DLL is in a stable tracking state.

**Autocorrelation Function from Multi-correlator output**
![image](https://github.com/user-attachments/assets/5feecdfe-e1bb-4038-b1a0-592dc2db1b07)

**Symmetric and Undistorted ACF:** The shape of the Autocorrelation Function (ACF) is symmetric and undistorted, indicating that the satellite signal is not affected by multipath interference. This aligns with the open sky scenario. **The above results demonstrate that the satellite in open sky conditions is well acquired and tracked.**

### 2.4 Tracking result from urban data (acquisition results from GPS satellite PRN 18)

![image](https://github.com/user-attachments/assets/78c5cf3b-513a-4edb-ace3-441da1704d2d)

**Q-Channel Not Always Near Zero:** The Q-channel sometimes exceeds the I-channel, indicating that not all energy is concentrated on the I-channel. This suggests that the carrier phase is not always well aligned.

![image](https://github.com/user-attachments/assets/6890c144-abf8-4c6f-8fc1-981b79199ef7)

**DLL Output Similar to Open Sky:** The Code Discriminator Output (DLL) is similar to that in open sky conditions.

![image](https://github.com/user-attachments/assets/837709c8-565f-4da8-af7d-3385b688fc60)

**PLL Output Not Always Near Zero:** The Phase/Frequency Discriminator Output (PLL) shows significant fluctuations, indicating that the local carrier is not always synchronized with the received signal carrier, leading to unstable carrier tracking.

![image](https://github.com/user-attachments/assets/89f84c68-d367-4d0c-bf0a-d8d851d2f535)

**Prompt Correlation Not Always Greater than Early/Late:** The Prompt correlation is sometimes weaker than Early/Late, especially **when the PLL output is high**, indicating that the carrier phases are not precisely aligned.

![fc619ab07ec3f9a56eb0863fddb3386](https://github.com/user-attachments/assets/3472b606-dcf2-440d-a308-5a119ccfbb24)

**Asymmetric Multi-Correlator Output:** The ACF is distorted due to multipath interference, leading to incorrect pseudorange measurements and reduced positioning accuracy. **The above results demonstrate that the satellite in urban conditions is not well acquired and tracked.**

## Task 3: Navigation data decoding (PRN 16 Open-Sky and PRN 18 urban as an Example)
![image](https://github.com/user-attachments/assets/25346100-71d7-473d-af67-2d54fb2ac657)

The above image shows the navigation data message decoded from the incoming signal in an open sky environment.

![image](https://github.com/user-attachments/assets/3912012d-3d7c-422f-84a3-fa7bc758c930)

The above image shows the navigation data message decoded from the incoming signal in an urban environment. Compared to the open sky data, the amplitude is not stable, indicating that the energy is not concentrated on the I-channel. This further proves that the received signal is not well tracked in urban conditions.

Key Parameters Extracted from Navigation Message. **Ephemeris Data (31 parameters)**

![image](https://github.com/user-attachments/assets/8726c04c-6d76-4b80-94af-26dca388a5ef)

## Task 4: Position and velocity estimation
**Weighted least square for positioning**

**Elevation weighted**

```
     weight(i)=sin(el(i))^2;
......
    W=diag(weight);
    C=W'*W;
    x=(A'*C*A)\(A'*C*omc);
```

**Weighted least square for velocity**

```
%===To calculate receiver velocity=====HD
b=[];
lamda=settings.c/1575.42e6;
rate=-lamda*doppler;
rate=rate';
satvelocity=satvelocity';
for i=1:nmbOfSatellites
    b(i)=rate(i)-satvelocity(i,:)*(A(i,1:3))';
end
v=(A'*C*A)\(A'*C*b');
```

### The positioning result of the open sky scenario is shown below, where the yellow dot represents the ground truth
![image](https://github.com/user-attachments/assets/f9209b1d-1ba0-40dc-acae-dcfad9d21c58)

The weighted least squares (WLS) solution demonstrates **high accuracy** in open sky environments, closely aligning with ground truth measurements. This precision is due to the absence of significant signal propagation impairments such as multipath interference and non-line-of-sight (NLOS) errors under unobstructed conditions.

![image](https://github.com/user-attachments/assets/eae97665-a27f-470b-b9df-61c1d169205f)
![image](https://github.com/user-attachments/assets/b5f481d8-2eed-43a6-9e54-5564f1663bad)

### The positioning result of the urban scenario is shown below, where the yellow dot represents the ground truth.

Urban GNSS positioning suffers from **reduced accuracy** compared to open environments due to signal obstruction by buildings, multipath reflections, and non-line-of-sight (NLOS) reception, which distort satellite measurements. These challenges degrade geometric diversity (e.g., fewer visible satellites, higher DOP) and introduce meter-level errors.

![image](https://github.com/user-attachments/assets/7ff39f64-60eb-443d-8142-01e4fa41a4d9)
![image](https://github.com/user-attachments/assets/a9a73960-67d5-47b6-8a8a-134caf10fce0)
![image](https://github.com/user-attachments/assets/2b95eb92-24ca-45b8-9e92-0ad5ef8aa55e)

The velocity estimated by WLS varies significantly if no filtering is applied.

## Task 5: Kalman-filter based positioning and velociy
The Extended Kalman Filter (EKF) is applied here.
···
**State Vector: [x,y,z,vx,vy,vz,dt,ddt](Position, velocity, clock error and clock drift)**
```
% prediction 
X_kk = F * X;
P_kk = F*P*F'+Q;
...
r = Z - h_x;
S = H * P_kk * H' + R;
K = P_kk * H' /S; % Kalman Gain

% Update State Estimate
X_k = X_kk + (K * r);
I = eye(size(X, 1));
P_k = (I - K * H) * P_kk * (I - K * H)' + K * R * K';
```
**Comparison with Weighted Least Squares (WLS)**

Kalman Filter-based positioning provides smoother trajectories with fewer abrupt jumps or outliers compared to traditional Weighted Least Squares (WLS). This enhanced stability is due to the Kalman Filter's dynamic state estimation capabilities.

The Kalman Filter outperforms WLS by incorporating temporal continuity, dynamic noise adaptation, and recursive state estimation. Unlike WLS, which processes each epoch independently and is susceptible to measurement noise-induced jumps, the Kalman Filter uses a state-space model to propagate estimates forward using motion dynamics (velocity and clock drift). It dynamically balances process noise (Q) and measurement noise (R) to suppress outliers and model uncertainties.

### Positioning Results of EKF in Open Sky
![image](https://github.com/user-attachments/assets/4775e670-9c09-48aa-915e-b9680190e555)

![image](https://github.com/user-attachments/assets/2e2dec31-5c69-4bdc-984a-d33901594efc)

The velocity after applying the Extended Kalman Filter is also significantly improved compared to WLS.

![image](https://github.com/user-attachments/assets/6ac7d05a-1bcb-46e9-aadc-746a770ceb2b)

### Positioning Results of EKF in Urban Area

![image](https://github.com/user-attachments/assets/1c6f0ad2-70ca-49ef-91e6-b74c8fd5e124)

![image](https://github.com/user-attachments/assets/d72b7f25-4cfd-4838-b222-87fcfb7861bb)

The velocity after applying the Kalman Filter:

![image](https://github.com/user-attachments/assets/b7f19a64-cfe0-4ee7-b7a4-7c29e01f01cc)

Compared to the open-sky environment, the positioning and velocity in urban areas are less accurate.
