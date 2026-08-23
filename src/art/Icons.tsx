type P = { size?: number; className?: string; strokeWidth?: number }
const base = (size: number) => ({
  width: size, height: size, viewBox: '0 0 24 24', fill: 'none',
  stroke: 'currentColor', strokeLinecap: 'round' as const, strokeLinejoin: 'round' as const,
})

export const IconSearch = ({ size = 20, className, strokeWidth = 1.9 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></svg>
)
export const IconBell = ({ size = 20, className, strokeWidth = 1.8 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="M18 8a6 6 0 1 0-12 0c0 5-2 6-2 6h16s-2-1-2-6" /><path d="M13.7 20a2 2 0 0 1-3.4 0" /></svg>
)
export const IconBag = ({ size = 20, className, strokeWidth = 1.8 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="M5 8h14l-1 12H6L5 8Z" /><path d="M9 8V6a3 3 0 0 1 6 0v2" /></svg>
)
export const IconHome = ({ size = 20, className, strokeWidth = 1.9 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="M4 10.5 12 4l8 6.5V19a1 1 0 0 1-1 1h-4v-5h-6v5H5a1 1 0 0 1-1-1v-8.5Z" /></svg>
)
export const IconChat = ({ size = 20, className, strokeWidth = 1.8 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="M20 15a2 2 0 0 1-2 2H8l-4 3V6a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v9Z" /></svg>
)
export const IconHeart = ({ size = 20, className, strokeWidth = 1.8, filled = false }: P & { filled?: boolean }) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className} fill={filled ? 'currentColor' : 'none'}>
    <path d="M12 20s-7-4.4-7-9.3A4.2 4.2 0 0 1 12 7.7a4.2 4.2 0 0 1 7 3c0 4.9-7 9.3-7 9.3Z" />
  </svg>
)
export const IconBookmark = ({ size = 20, className, strokeWidth = 1.8 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="M7 4h10a1 1 0 0 1 1 1v15l-6-4-6 4V5a1 1 0 0 1 1-1Z" /></svg>
)
export const IconUser = ({ size = 20, className, strokeWidth = 1.8 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><circle cx="12" cy="9" r="3.4" /><path d="M5.5 20a6.5 6.5 0 0 1 13 0" /></svg>
)
export const IconBack = ({ size = 20, className, strokeWidth = 2 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="M15 5l-7 7 7 7" /></svg>
)
export const IconChevron = ({ size = 20, className, strokeWidth = 2 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="M9 5l7 7-7 7" /></svg>
)
export const IconChevronDown = ({ size = 16, className, strokeWidth = 2 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="M5 9l7 7 7-7" /></svg>
)
export const IconPlus = ({ size = 18, className, strokeWidth = 2.2 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="M12 5v14M5 12h14" /></svg>
)
export const IconMinus = ({ size = 18, className, strokeWidth = 2.2 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="M5 12h14" /></svg>
)
export const IconGrid = ({ size = 22, className }: P) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" className={className}>
    {[6, 12, 18].map((y) => [6, 12, 18].map((x) => <circle key={`${x}-${y}`} cx={x} cy={y} r="1.7" />))}
  </svg>
)
export const IconPin = ({ size = 20, className, strokeWidth = 1.8 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="M12 21s6-5.3 6-10a6 6 0 1 0-12 0c0 4.7 6 10 6 10Z" /><circle cx="12" cy="11" r="2.2" /></svg>
)
export const IconMore = ({ size = 20, className }: P) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" className={className}>
    <circle cx="12" cy="5.5" r="1.7" /><circle cx="12" cy="12" r="1.7" /><circle cx="12" cy="18.5" r="1.7" />
  </svg>
)
export const IconStar = ({ size = 13, className, filled = true }: P & { filled?: boolean }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={filled ? 'currentColor' : 'none'} stroke="currentColor" strokeWidth="1.6" className={className}>
    <path d="m12 3.6 2.6 5.3 5.9.85-4.25 4.15 1 5.85L12 16.99 6.75 19.75l1-5.85L3.5 9.75l5.9-.85L12 3.6Z" />
  </svg>
)
export const IconCheck = ({ size = 16, className, strokeWidth = 2.6 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}><path d="m5 12.5 4.5 4.5L19 7.5" /></svg>
)
export const IconFlame = ({ size = 16, className, strokeWidth = 1.8 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}>
    <path d="M12 3s4.5 3.6 4.5 8a4.5 4.5 0 0 1-9 0c0-1.6.8-2.8.8-2.8S9 10 10 10c1.4 0 .5-4.5 2-7Z" />
  </svg>
)
export const IconRuler = ({ size = 16, className, strokeWidth = 1.8 }: P) => (
  <svg {...base(size)} strokeWidth={strokeWidth} className={className}>
    <rect x="3" y="8" width="18" height="8" rx="2" /><path d="M8 8v3M12 8v4M16 8v3" />
  </svg>
)

/* Payment brand marks — drawn, not fetched. */
export const LogoMastercard = ({ size = 26 }: P) => (
  <svg width={size} height={size} viewBox="0 0 32 32"><circle cx="12.5" cy="16" r="8" fill="#eb001b" /><circle cx="19.5" cy="16" r="8" fill="#f79e1b" /><path d="M16 9.8a8 8 0 0 0 0 12.4 8 8 0 0 0 0-12.4Z" fill="#ff5f00" /></svg>
)
export const LogoPaypal = ({ size = 26 }: P) => (
  <svg width={size} height={size} viewBox="0 0 32 32">
    <path d="M11 25 13.4 8.5h6.1c3.3 0 5 1.7 4.5 4.6-.5 3.3-2.9 5-6.4 5h-2.4L14.4 25Z" fill="#27346a" />
    <path d="M9 27 11.4 10.5h6.1c3.3 0 5 1.7 4.5 4.6-.5 3.3-2.9 5-6.4 5h-2.4L12.4 27Z" fill="#2790c3" />
  </svg>
)
export const LogoApple = ({ size = 26 }: P) => (
  <svg width={size} height={size} viewBox="0 0 32 32" fill="#000">
    <path d="M21.3 16.9c0-2.7 2.2-4 2.3-4.1-1.3-1.8-3.2-2.1-3.9-2.1-1.7-.2-3.3 1-4.1 1-.9 0-2.2-1-3.6-1-1.8 0-3.5 1.1-4.5 2.7-1.9 3.3-.5 8.3 1.4 11 .9 1.3 2 2.8 3.4 2.7 1.4-.1 1.9-.9 3.5-.9s2.1.9 3.6.8c1.5 0 2.4-1.3 3.3-2.7 1-1.5 1.5-3 1.5-3.1-.1 0-2.9-1.1-2.9-4.3ZM18.7 8.9c.8-.9 1.3-2.2 1.1-3.5-1.1 0-2.4.7-3.2 1.6-.7.8-1.3 2.1-1.1 3.4 1.2.1 2.4-.6 3.2-1.5Z" />
  </svg>
)
