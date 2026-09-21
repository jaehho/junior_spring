import numpy as np
import matplotlib.pyplot as plt
from typing import Union, Dict, Any, List, Tuple

def fast_spike_generator(
    r: Union[float, np.ndarray],
    T: float = 1,
    dt: float = 0.001,
    abs_ref: float = 0.001,
    rel_ref_mean: float = 0.01,
    return_refractory_periods: bool = False,
) -> Dict[str, Dict[str, Any]]:
    """Generate a dictionary of spike trains driven by a Poisson process.

    Args:
        r (Union[float, np.ndarray]): Constant firing rate if scalar or time varying array of firing rates at each time step (Hz).
        T (float, optional): Trial duration (s). Defaults to 1.
        dt (float, optional): Time step size of `r_t` (s). Defaults to 0.001.
        abs_ref (float, optional): Absolute refractory period (s). Defaults to 0.001.
        rel_ref_mean (float, optional): Mean relative refractory period (s). Defaults to 0.01.
        return_refractory_periods (bool, optional): Flag to return refractory periods in dict. Defaults to False.
    Returns:
        (Dict[str, Any]): {"Spike Times Poisson": np.ndarray, "Spike Times Refractory": np.ndarray, "Refractory Periods": list}
    """
    rng = np.random.default_rng()
    # Use a homogeneous poisson process if r is scalar, inhomogeneous otherwise (r should be an array of the same length as spike_train)
    homogeneous = np.isscalar(r)         
    if homogeneous:
        max_firing_rate = r
    else:
        max_firing_rate = max(r)
    interspike_intervals = rng.exponential(scale=1/max_firing_rate, size=round(max_firing_rate * T * 2))
    spike_times = np.cumsum(interspike_intervals)
    spike_times = spike_times[spike_times < T] # Cutoff at extra spikes at T
    spike_times_homogeneous = spike_times.copy()
    
    # Spike thinning for inhomogeneous Poisson process
    if not homogeneous:
        spike_indices_to_remove = []
        for i, spike_time in enumerate(spike_times):
            firing_rate_index = round(spike_time / dt) - 1 # index of the spike time in the time varying firing rate array, -1 to account for 0 indexing
            if r_t[firing_rate_index] / max_firing_rate < rng.random():
                spike_indices_to_remove.append(i)
        spike_times = np.delete(spike_times, spike_indices_to_remove)
    spike_times_inhomogeneous = spike_times.copy()
        
    for spike_times in [spike_times_homogeneous, spike_times_inhomogeneous]:
        valid_spike_times = []
        refractory_periods = []
        i = 0
        while i < len(spike_times):
            current_time = spike_times[i]
            valid_spike_times.append(current_time)

            # The refractory period for this spike.
            ref_period = abs_ref + rng.exponential(scale=rel_ref_mean)
            refractory_periods.append((current_time, current_time + ref_period))

            # Skip any spikes within this refractory period
            i += 1
            while i < len(spike_times) and spike_times[i] < current_time + ref_period:
                i += 1
                
        if spike_times is spike_times_homogeneous:
            spike_times_homogeneous_refractory = np.array(valid_spike_times)
            refractory_periods_homogeneous = refractory_periods
        else:
            spike_times_inhomogeneous_refractory = np.array(valid_spike_times)
            refractory_periods_inhomogeneous = refractory_periods
    
    spikes_dict = {
        "Homogeneous": spike_times_homogeneous,
        "Homogeneous w/ Refractory Effects": spike_times_homogeneous_refractory,
        "Inhomogeneous": spike_times_inhomogeneous,
        "Inhomogeneous w/ Refractory Effects": spike_times_inhomogeneous_refractory
    }
    
    if return_refractory_periods:
        spikes_dict.update({
            "Homogeneous Refractory Periods": refractory_periods_homogeneous,
            "Inhomogeneous Refractory Periods": refractory_periods_inhomogeneous
        })
    
    return spikes_dict

def raster_plot(ax:plt.Axes, spike_times:np.ndarray, highlight_ref: bool=True, refractory_periods: list=[], xlim=(0, 1), title="Raster plot"):
    # Plot vertical lines for each spike.
    ax.vlines(spike_times, 0, 1)
    
    # Overlay the refractory periods if highlight_ref is True.
    if highlight_ref and any(refractory_periods):
        for start, end in refractory_periods:
            ax.axvspan(start, end, color='red', alpha=0.3)
        
    ax.set_ylim(0, 1)
    ax.set_xlim(xlim)
    ax.get_yaxis().set_visible(False)
    ax.set_title(title)
    
class PoissonSpikeGenerator:
    def __init__(
        self,
        T: float = 1.0,
        dt: float = 0.001,
        abs_ref: float = 0.001,
        rel_ref_mean: float = 0.01,
        seed: int = None
    ):
        self.T = T
        self.dt = dt
        self.abs_ref = abs_ref
        self.rel_ref_mean = rel_ref_mean
        self.rng = np.random.default_rng(seed)
        self.spikes = {}

    def generate(
        self,
        r: Union[float, np.ndarray],
        return_refractory_periods: bool = False
    ) -> Dict[str, Any]:
        homogeneous = np.isscalar(r)
        max_firing_rate = r if homogeneous else max(r)
        n_spikes = int(max_firing_rate * self.T * 2)

        interspike_intervals = self.rng.exponential(scale=1 / max_firing_rate, size=n_spikes)
        spike_times = np.cumsum(interspike_intervals)
        spike_times = spike_times[spike_times < self.T]
        spike_times_homogeneous = spike_times.copy()

        if not homogeneous:
            spike_indices_to_remove = []
            for i, spike_time in enumerate(spike_times):
                index = round(spike_time / self.dt) - 1
                if r[index] / max_firing_rate < self.rng.random():
                    spike_indices_to_remove.append(i)
            spike_times = np.delete(spike_times, spike_indices_to_remove)
        spike_times_inhomogeneous = spike_times.copy()

        def apply_refractory(spike_times: np.ndarray) -> Tuple[np.ndarray, List[Tuple[float, float]]]:
            valid_spike_times = []
            refractory_periods = []
            i = 0
            while i < len(spike_times):
                current_time = spike_times[i]
                valid_spike_times.append(current_time)
                ref_period = self.abs_ref + self.rng.exponential(scale=self.rel_ref_mean)
                refractory_periods.append((current_time, current_time + ref_period))
                i += 1
                while i < len(spike_times) and spike_times[i] < current_time + ref_period:
                    i += 1
            return np.array(valid_spike_times), refractory_periods

        spike_times_homogeneous_refractory, refractory_hom = apply_refractory(spike_times_homogeneous)
        spike_times_inhomogeneous_refractory, refractory_inhom = apply_refractory(spike_times_inhomogeneous)

        self.spikes = {
            "Homogeneous": spike_times_homogeneous,
            "Homogeneous w/ Refractory Effects": spike_times_homogeneous_refractory,
            "Inhomogeneous": spike_times_inhomogeneous,
            "Inhomogeneous w/ Refractory Effects": spike_times_inhomogeneous_refractory
        }

        if return_refractory_periods:
            self.spikes.update({
                "Homogeneous Refractory Periods": refractory_hom,
                "Inhomogeneous Refractory Periods": refractory_inhom
            })

        return self.spikes

    def raster_plot(
        self,
        ax: plt.Axes,
        key: str,
        xlim: Tuple[float, float] = (0, 1),
        title: str = "Raster plot"
    ):
        if key not in self.spikes:
            raise ValueError(f"'{key}' not found in generated spike data.")
        
        spike_times = self.spikes[key]
        refractory_periods = []

        ax.vlines(spike_times, 0, 1)
        ax.set_ylim(0, 1)
        ax.set_xlim(xlim)
        ax.get_yaxis().set_visible(False)
        ax.set_title(title)
        ax.set_xlabel("Time (s)")

# Example usage
if __name__ == "__main__":
    T = 1
    dt = 0.001
    r_t = np.repeat([1, 30, 60, 30, 1], round((T/dt)/5))

    generator = PoissonSpikeGenerator(T=T, dt=dt, abs_ref=0.001, rel_ref_mean=0.01, seed=42)
    generator.generate(r_t)

    fig, axes = plt.subplots(4, 1, figsize=(15, 6), sharex=True)
    for ax, key in zip(axes, generator.spikes.keys()):
        generator.raster_plot(ax, key=key, title=key)
    
    fig.tight_layout()
    fig.savefig("processes.svg", transparent=True)
    print(generator.spikes.keys())
