export type Root = {
    type: string
    crs: {
        type: string
        properties: {
            name: string
        }
    }
    features: Array<{
        type: string
        properties: {
            shapeName: string
            shapeISO: string
            shapeID: string
            shapeGroup: string
            shapeType: string
        }
        geometry: {
            type: string
            coordinates: Array<Array<Array<any>>>
        }
    }>
}

// Notes:
// - geometry.type can be "Polygon" or "MultiPolygon".
// - coordinates are assumed to be [longitude, latitude] pairs.
