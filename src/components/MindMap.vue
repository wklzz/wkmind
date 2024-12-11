<template>
  <div class="mind-map-container">
    <div class="toolbar">
      <button @click="addNode">添加节点</button>
      <button @click="exportImage">导出图片</button>
    </div>
    <div ref="mindMapRef" class="mind-map"></div>
  </div>
</template>

<script>
import { ref, onMounted, watch } from 'vue'
import * as d3 from 'd3'
import html2canvas from 'html2canvas'

export default {
  name: 'MindMap',
  setup() {
    const mindMapRef = ref(null)
    const data = ref({
      id: '1',
      name: '中心主题',
      children: [],
      _collapsed: false
    })

    let svg = null
    let g = null

    const deleteNode = (nodeData) => {
      const deleteFromChildren = (children, id) => {
        const index = children.findIndex(child => child.id === id)
        if (index !== -1) {
          children.splice(index, 1)
          return true
        }
        for (let child of children) {
          if (child.children && deleteFromChildren(child.children, id)) {
            return true
          }
        }
        return false
      }

      if (nodeData.data.id !== '1') {
        deleteFromChildren(data.value.children, nodeData.data.id)
        updateMindMap()
      }
    }

    const toggleNode = (d) => {
      d.data._collapsed = !d.data._collapsed
      updateMindMap()
    }

    const initMindMap = () => {
      const width = 800
      const height = 600
      
      d3.select(mindMapRef.value).selectAll('svg').remove()
      
      svg = d3.select(mindMapRef.value)
        .append('svg')
        .attr('width', width)
        .attr('height', height)

      const zoom = d3.zoom()
        .scaleExtent([0.1, 3])
        .on('zoom', (event) => {
          g.attr('transform', event.transform)
        })

      svg.call(zoom)

      g = svg.append('g')
        .attr('transform', `translate(${width/4},${height/2})`)

      updateMindMap()
    }

    const updateMindMap = () => {
      const tree = d3.tree()
        .nodeSize([80, 200])

      const processData = (node) => {
        return {
          ...node,
          children: node._collapsed ? null : 
            (node.children ? node.children.map(processData) : null)
        }
      }

      const processedData = processData(data.value)
      const root = d3.hierarchy(processedData)
      tree(root)

      const links = g.selectAll('.link')
        .data(root.links())
        .join('path')
        .attr('class', 'link')
        .attr('d', d3.linkHorizontal()
          .x(d => d.y)
          .y(d => d.x))

      const nodes = g.selectAll('.node')
        .data(root.descendants())
        .join('g')
        .attr('class', 'node')
        .attr('transform', d => `translate(${d.y},${d.x})`)

      nodes.selectAll('rect')
        .data(d => [d])
        .join('rect')
        .attr('x', -50)
        .attr('y', -20)
        .attr('width', 100)
        .attr('height', 40)
        .attr('rx', 5)
        .attr('ry', 5)

      nodes.selectAll('text.node-text')
        .data(d => [d])
        .join('text')
        .attr('class', 'node-text')
        .text(d => d.data.name)
        .attr('text-anchor', 'middle')
        .attr('dominant-baseline', 'middle')
        .style('font-size', '14px')
        .style('user-select', 'none')

      nodes.each(function(d) {
        const node = d3.select(this)
        node.selectAll('.toggle-btn').remove()
        
        if (d.data.children && d.data.children.length > 0) {
          node.append('text')
            .attr('class', 'toggle-btn')
            .text(d.data._collapsed ? '⊕' : '⊖')
            .attr('x', 60)
            .attr('y', 0)
            .style('cursor', 'pointer')
            .style('font-size', '18px')
            .on('click', (event) => {
              event.stopPropagation()
              toggleNode(d)
            })
        }

        if (d.data.id !== '1') {
          node.append('text')
            .attr('class', 'delete-btn')
            .text('×')
            .attr('x', -60)
            .attr('y', 0)
            .style('cursor', 'pointer')
            .style('font-size', '18px')
            .style('fill', '#ff4444')
            .on('click', (event) => {
              event.stopPropagation()
              deleteNode(d)
            })
        }
      })

      nodes.call(d3.drag()
        .on('drag', (event, d) => {
          d.x = event.y
          d.y = event.x
          updateMindMap()
        }))

      nodes.on('dblclick', (event, d) => {
        const newName = prompt('请输入节点名称：', d.data.name)
        if (newName) {
          d.data.name = newName
          updateMindMap()
        }
      })
    }

    const addNode = () => {
      const newNode = {
        id: Date.now().toString(),
        name: '新节点',
        children: [],
        _collapsed: false
      }
      if (!data.value.children) {
        data.value.children = []
      }
      data.value.children.push(newNode)
      updateMindMap()
    }

    const exportImage = async () => {
      const element = mindMapRef.value
      const canvas = await html2canvas(element)
      const link = document.createElement('a')
      link.download = 'mindmap.png'
      link.href = canvas.toDataURL()
      link.click()
    }

    watch(() => data.value, () => {
      updateMindMap()
    }, { deep: true })

    onMounted(() => {
      initMindMap()
    })

    return {
      mindMapRef,
      addNode,
      exportImage
    }
  }
}
</script>

<style scoped>
.mind-map-container {
  width: 100%;
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.toolbar {
  padding: 10px;
  border-bottom: 1px solid #eee;
}

.toolbar button {
  margin-right: 10px;
  padding: 5px 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  cursor: pointer;
}

.mind-map {
  flex: 1;
  overflow: hidden;
}

:deep(.link) {
  fill: none;
  stroke: #ccc;
  stroke-width: 2px;
}

:deep(.node rect) {
  fill: white;
  stroke: #4CAF50;
  stroke-width: 2px;
  cursor: pointer;
}

:deep(.node:hover rect) {
  fill: #f0f9f0;
}

:deep(.node text) {
  fill: #333;
}

:deep(.toggle-btn) {
  fill: #666;
}

:deep(.toggle-btn:hover) {
  fill: #4CAF50;
}

:deep(.delete-btn:hover) {
  fill: #ff0000;
}

:deep(.node-text) {
  cursor: pointer;
}
</style> 