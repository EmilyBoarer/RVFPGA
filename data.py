from matplotlib import pyplot as plt
import numpy as np

    # "blinky":[
    #     {
    #         "alm":          0,
    #         "totalreg":     0,
    #         "pins":         0,
    #         "totalbram":    0,
    #         "fmax85":       0,
    #         "fmax0":        0,
    #         "harts":        0,
    #     },
    # ],


maxvals = {
    "alm":         32070,
    "pins":         457,
    "totalbram":    4065280,
}

data = {
    # "blinky":[ ## just the example blinker and counter... basically theoretical max speed benchmark
    #     {
    #         "alm":          15,
    #         "totalreg":     30,
    #         "pins":         247,
    #         "totalbram":    0,
    #         "fmax85":       410.17,
    #         "fmax0":        390.02,
    #         "seed":         1,
    #     },
    # ],
    "RVFPGA(EuArch-2)":[
        {
            "alm":          2473,
            "totalreg":     6407,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       96.71,
            "fmax0":        100.06,
            "seed":         1,
        },
        {
            "alm":          2573,
            "totalreg":     6408,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       94.38,
            "fmax0":        97.94,
            "seed":         2,
        },
        {
            "alm":          2526,
            "totalreg":     6407,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       100.49,
            "fmax0":        103.31,
            "seed":         3,
        },
        {
            "alm":          2628,
            "totalreg":     6407,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       110.89,
            "fmax0":        113.92,
            "seed":         4,
        },
        {
            "alm":          2622,
            "totalreg":     6408,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       108.21,
            "fmax0":        109.31,
            "seed":         5,
        },
        {
            "alm":          2594,
            "totalreg":     6408,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       104.58,
            "fmax0":        105.26,
            "seed":         6,
        },
        {
            "alm":          2517,
            "totalreg":     6407,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       103.42,
            "fmax0":        106.26,
            "seed":         7,
        },
        {
            "alm":          2589,
            "totalreg":     6408,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       101.05,
            "fmax0":        101.19,
            "seed":         8,
        },
        {
            "alm":          2666,
            "totalreg":     6408,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       96.33,
            "fmax0":        100.15,
            "seed":         9,
        },
        {
            "alm":          2637,
            "totalreg":     6407,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       98.68,
            "fmax0":        98.41,
            "seed":         10,
        },
        {
            "alm":          2577,
            "totalreg":     6407,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       103.27,
            "fmax0":        103.37,
            "seed":         11,
        },
        {
            "alm":          2562,
            "totalreg":     6408,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       107.55,
            "fmax0":        107.81,
            "seed":         12,
        },
        {
            "alm":          2580,
            "totalreg":     6407,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       110.67,
            "fmax0":        114.6,
            "seed":         13,
        },
        {
            "alm":          2467,
            "totalreg":     6407,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       106.36,
            "fmax0":        109.33,
            "seed":         14,
        },
        {
            "alm":          2560,
            "totalreg":     6408,
            "pins":         247,
            "totalbram":    147456,
            "fmax85":       109.69,
            "fmax0":        111.83,
            "seed":         15,
        },
    ],
    "CLARVI":[
        {
            "alm":          2800,
            "totalreg":     3572,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       71.62,
            "fmax0":        73.46,
            "seed":         1,
        },
        {
            "alm":          2828,
            "totalreg":     3587,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       70.95,
            "fmax0":        73.82,
            "seed":         2,
        },
        {
            "alm":          2832,
            "totalreg":     3600,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       66.72,
            "fmax0":        69.46,
            "seed":         3,
        },
        {
            "alm":          2813,
            "totalreg":     3594,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       70.99,
            "fmax0":        72.48,
            "seed":         4,
        },
        {
            "alm":          2831,
            "totalreg":     3578,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       71.64,
            "fmax0":        73.32,
            "seed":         5,
        },
        {
            "alm":          2811,
            "totalreg":     3590,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       74.6,
            "fmax0":        75.55,
            "seed":         6,
        },
        { # 4:17 to run everything
            "alm":          2812,
            "totalreg":     3603,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       71.06,
            "fmax0":        72.56,
            "seed":         7,
        },
        { # 4:47
            "alm":          2815,
            "totalreg":     3585,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       72.65,
            "fmax0":        74.24,
            "seed":         8,
        },
        { # 4:43
            "alm":          2806,
            "totalreg":     3570,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       65.89,
            "fmax0":        68.04,
            "seed":         9,
        },
        { # 4:51
            "alm":          2830,
            "totalreg":     3615,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       69.4,
            "fmax0":        70.9,
            "seed":         10,
        },
        { # 4:63
            "alm":          2823,
            "totalreg":     3621,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       68.64,
            "fmax0":        70.27,
            "seed":         11,
        },
        { # 4:55
            "alm":          2822,
            "totalreg":     3584,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       69.72,
            "fmax0":        70.77,
            "seed":         12,
        },
        { # 4:16
            "alm":          2806,
            "totalreg":     3590,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       69.17,
            "fmax0":        70.39,
            "seed":         13,
        },
        { # 4:39
            "alm":          2816,
            "totalreg":     3594,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       73.35,
            "fmax0":        73.9,
            "seed":         14,
        },
        { # 4:16
            "alm":          2813,
            "totalreg":     3570,
            "pins":         246,
            "totalbram":    2621750,
            "fmax85":       68.28,
            "fmax0":        69.5,
            "seed":         15,
        },
    ],
}

harts = {
    "blinky":0,
    "RVFPGA(EuArch-2)":6,
    # "RVFPGA(EuArch-2) (1-hart)":1,
    # "RVFPGA(EuArch-2) (3-hart)":3,
    "CLARVI":1,
}

expected_instructions_per_cycle = {
    "blinky":0,
    "RVFPGA(EuArch-2)":1/harts["RVFPGA(EuArch-2)"], # branching not a concern under our memory model
    # "RVFPGA(EuArch-2) (1-hart)":1/harts["RVFPGA(EuArch-2)"], # branching not a concern under our memory model
    # "RVFPGA(EuArch-2) (3-hart)":1/harts["RVFPGA(EuArch-2)"], # branching not a concern under our memory model
    "CLARVI":7/11, # accounts for branching, but not stalls from memory not ready => parity with euarch
}



## plot
fig, ax = plt.subplots()

def box_plot_things(ax, f, yunit, xunit, label=True):

    labs = []
    vals = []
    for model, runs in data.items():
        v,l = f(model, runs)
        if l != None:
            labs.append(l)
            vals.append(v)
    if label:
        ax.boxplot(
            vals,
            vert=True,
            labels=labs,
            widths=0.7)
    else:
        ax.boxplot(
            vals,
            vert=True,
            labels=["" for _ in range(len(labs))],
            widths=0.7)
        # ax.set_ylabel("")

    ax.set_ylabel(yunit)
    ax.set_title(xunit)
    ax.yaxis.grid(True)
    ax.set_ylim(ymin=0)


fig.set_size_inches(6,7)

## plot fmax
box_plot_things(ax,
                lambda model, runs: ([(run["fmax85"]+run["fmax0"])/2 for run in runs],model),
                "MHz", "mean Fmax [higher = better]")


# box_plot_things(axes[0][1],
#                 lambda model, runs: ([(run["alm"]/maxvals["alm"])*100 for run in runs],model),
#                 "%", "Logic Utilisation [lower = better]")



# ## plot performance
# box_plot_things(ax,
#                 lambda model, runs: ([
#                     expected_instructions_per_cycle[model] * harts[model] * run["fmax0"]
#                     for run in runs],
#                     f"{model}\n(1,3,6 harts)" if model == "RVFPGA(EuArch-2)" else model ),
#                 "mega-instructions per second", "Performance [higher = better]")
# box_plot_things(ax,
#                 lambda model, runs: ([
#                     expected_instructions_per_cycle[model] * (1 if model == "RVFPGA(EuArch-2)" else harts[model]) * run["fmax0"]
#                     for run in runs],
#                     "" if model == "RVFPGA(EuArch-2)" else None ),
#                 "mega-instructions per second", "Performance [higher = better]", False)
# box_plot_things(ax,
#                 lambda model, runs: ([
#                     expected_instructions_per_cycle[model] * (3 if model == "RVFPGA(EuArch-2)" else harts[model]) * run["fmax0"]
#                     for run in runs],
#                     "" if model == "RVFPGA(EuArch-2)" else None),
#                 "mega-instructions per second", "Performance [higher = better]", False)




# box_plot_things(axes[1][1],
#                 lambda model, runs: [
#                     expected_instructions_per_cycle[model] * harts[model] * run["fmax0"]
#                     for run in runs],
#                 "mega-instructions per second", "Performance (total) [higher = better]")

plt.show()