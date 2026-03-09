/// <reference types="vite/client" />

declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}
declare module '*.svg?component' {
  import { DefineComponent, SVGAttributes } from 'vue'
  const component: DefineComponent<SVGAttributes>
  export default component
}
