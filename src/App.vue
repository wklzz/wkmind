<template>
  <div class="app">
    <MindMap />
  </div>
</template>

<script>
import MindMap from './components/MindMap.vue'

export default {
  name: 'App',
  components: {
    MindMap
  }
}
</script>

<style>
.app {
  height: 100vh;
  margin: 0;
  padding: 0;
}
</style> 