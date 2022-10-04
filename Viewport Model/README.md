# Viewport-Model-TS

This contains the typing for [EgoMoose's Viewport Model](https://gist.github.com/EgoMoose/2fd62ee98754380f6d839267ffe4f588)

## Usage

### Functions

```TS
    new( viewportFrame: ViewportFrame, camera: Camera ): ViewportModelClass;

    /**
     * Does the work to display a Model in the Viewport Frame
     */
    GenerateViewport ( viewportFrame: ViewportFrame, model: Model, orientation?: CFrame ): void

    /**
     * Removes previous Model from Viewport Frame
     */
    CleanViewport (viewportFrame: ViewportFrame) : void
```

### Viewport Model Class Methods

```TS
    /**
     * Used to set the model that is being focused on
     *
     * should be used for new models and/or a change in the current model
     *
     * e.g. parts added/removed from the model or the model cframe changed
     */
    SetModel ( model: Model ): void;

    /**
     * Should be called when something about the viewport frame / camera changes
     *
     * e.g. the frame size or the camera field of view
     */
    Calibrate (): void;

    /**
     * returns a fixed distance that is guarnteed to encapsulate the full model
     *
     * this is useful for when you want to rotate freely around an object w/o expensive calculations
     *
     * focus position can be used to set the origin of where the camera's looking
     *
     * otherwise the model's center is assumed
     */
    GetFitDistance ( focusPosition: Vector3 ): Vector3;

    /**
     * returns the optimal camera cframe that would be needed to best fit
     *
     * the model in the viewport frame at the given orientation.
     *
     * keep in mind this functions best when the model's point-cloud is correct
     *
     * as such models that rely heavily on meshesh, csg, etc will only return an accurate
     *
     * result as their point cloud
     */
    GetMinimumFitCFrame(orientation: CFrame): CFrame;
```