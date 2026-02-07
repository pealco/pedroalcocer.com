export interface Photo {
  src: string;
  alt: string;
  width: number;
  height: number;
}

export const photos: Photo[] = [
  { src: 'https://placehold.co/1200x800/111/333', alt: 'Placeholder 1', width: 1200, height: 800 },
  { src: 'https://placehold.co/800x1200/111/333', alt: 'Placeholder 2', width: 800, height: 1200 },
  { src: 'https://placehold.co/1200x900/111/333', alt: 'Placeholder 3', width: 1200, height: 900 },
  { src: 'https://placehold.co/900x1200/111/333', alt: 'Placeholder 4', width: 900, height: 1200 },
  { src: 'https://placehold.co/1200x800/111/333', alt: 'Placeholder 5', width: 1200, height: 800 },
  { src: 'https://placehold.co/1000x1000/111/333', alt: 'Placeholder 6', width: 1000, height: 1000 },
  { src: 'https://placehold.co/800x1200/111/333', alt: 'Placeholder 7', width: 800, height: 1200 },
  { src: 'https://placehold.co/1200x800/111/333', alt: 'Placeholder 8', width: 1200, height: 800 },
];
